//
// Copyright 2025 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import GRDB

public enum BackupAttachmentQueueType: Equatable, CaseIterable {
    case upload
    case download
}

public enum BackupAttachmentQueueStatus: Equatable {
    /// Running and up-/down- loading attachments off the queue
    case running

    /// The user has not yet opted to begin downloads.
    case suspended

    /// There's nothing to up-/down- load!
    case empty

    /// Must be registered and isAppReady to up-/down- load.
    case notRegisteredAndReady
    /// Wifi (not cellular) is required to up-/down- load.
    case noWifiReachability
    /// The device has low battery or is in low power mode.
    case lowBattery
    /// There is not enough disk space to finish downloading.
    /// Note that we require a minimum amount of space and will continue
    /// greedily downloading until this minimum is reached even if we know
    /// ahead of time we will hit the threshold before finishing.
    /// Does not apply to upload.
    case lowDiskSpace

    public static let didChangeNotification = Notification.Name(rawValue: "BackupAttachmentDownloadQueueStatusDidChange")
    public static let notificationQueueTypeKey = "BackupAttachmentQueueType"
}

/// Observes various inputs that determine whether we are abke to download backup-sourced
/// attachments and emits consolidated status updates.
/// Main actor isolated because most of its inputs are themselves main actor isolated.
@MainActor
public protocol BackupAttachmentQueueStatusManager {
    func currentStatus(type: BackupAttachmentQueueType) -> BackupAttachmentQueueStatus

    nonisolated func minimumRequiredDiskSpaceToCompleteDownloads() -> UInt64

    /// Re-triggers disk space checks and clears any in-memory state for past disk space errors,
    /// in order to attempt download resumption.
    func reattemptDiskSpaceChecks()
}

@MainActor
/// API just for BackupAttachmentDownloadManager to update the state in this class.
public protocol BackupAttachmentQueueStatusUpdates: BackupAttachmentQueueStatusManager {

    /// Check the current state _and_ begin observing state changes if the queue of backup up-/down- loads is not empty.
    func beginObservingIfNeeded(type: BackupAttachmentQueueType) -> BackupAttachmentQueueStatus

    /// Synchronously check remaining disk space.
    /// If there is sufficient space, early exit and return nil.
    /// Otherwise, await a full state update and return the updated status.
    nonisolated func quickCheckDiskSpaceForDownloads() async -> BackupAttachmentQueueStatus?

    /// Checks if the error should change the status (e.g. out of disk space errors should stop subsequent downloads)
    /// Returns nil if the error has no effect on the status (though note the status may be changed for any other concurrent
    /// reason unrelated to the error).
    nonisolated func jobDidExperienceError(type: BackupAttachmentQueueType, _ error: Error) async -> BackupAttachmentQueueStatus?

    /// Call when the QueuedBackupAttachmentRecord table is emptied.
    func didEmptyQueue(type: BackupAttachmentQueueType)
}

@MainActor
public class BackupAttachmentQueueStatusManagerImpl: BackupAttachmentQueueStatusUpdates {

    // MARK: - API

    public func currentStatus(type: BackupAttachmentQueueType) -> BackupAttachmentQueueStatus {
        return state.status(type: type)
    }

    public nonisolated func minimumRequiredDiskSpaceToCompleteDownloads() -> UInt64 {
        return getRequiredDiskSpace()
    }

    public func reattemptDiskSpaceChecks() {
        // Check for disk space available now in case the user freed up space.
        self.availableDiskSpaceMaybeDidChange()
        // Also, if we had experienced an error for some individual download before,
        // clear that now. If our check for disk space says we've got space but then
        // actual downloads fail with a disk space error...this will put us in a
        // loop of attempting over and over when the user acks. But if we don't do
        // this, the user has no (obvious) way to get out of running out of space.
        self.state.downloadDidExperienceOutOfSpaceError = false
    }

    public func beginObservingIfNeeded(type: BackupAttachmentQueueType) -> BackupAttachmentQueueStatus {
        observeDeviceAndLocalStatesIfNeeded()
        return currentStatus(type: type)
    }

    public nonisolated func jobDidExperienceError(type: BackupAttachmentQueueType, _ error: Error) async -> BackupAttachmentQueueStatus? {
        switch type {
        case .upload:
            return nil
        case .download:
            // We only care about out of disk space errors for downloads.
            guard (error as NSError).code == NSFileWriteOutOfSpaceError else {
                // Return nil to avoid having to thread-hop to the main thread just to get
                // the current status when we know it won't change due to this error.
                return nil
            }
            return await MainActor.run {
                return self.downloadDidExperienceOutOfSpaceError()
            }
        }
    }

    public nonisolated func quickCheckDiskSpaceForDownloads() async -> BackupAttachmentQueueStatus? {
        let requiredDiskSpace = self.getRequiredDiskSpace()
        if
            let availableDiskSpace = self.getAvailableDiskSpace(),
            availableDiskSpace < requiredDiskSpace
        {
            await self.availableDiskSpaceMaybeDidChange()
            return await self.state.status(type: .download)
        } else {
            return nil
        }
    }

    public func didEmptyQueue(type: BackupAttachmentQueueType) {
        switch type {
        case .upload:
            state.isUploadQueueEmpty = true
        case .download:
            state.isDownloadQueueEmpty = true
        }
        stopObservingDeviceAndLocalStates()
    }

    // MARK: - Init

    private let appContext: AppContext
    private let appReadiness: AppReadiness
    private let backupAttachmentDownloadStore: BackupAttachmentDownloadStore
    private let backupAttachmentUploadStore: BackupAttachmentUploadStore
    private let backupSettingsStore: BackupSettingsStore
    private let dateProvider: DateProvider
    private let db: DB
    private let deviceBatteryLevelManager: (any DeviceBatteryLevelManager)?
    private let reachabilityManager: SSKReachabilityManager
    private nonisolated let remoteConfigManager: RemoteConfigManager
    private let tsAccountManager: TSAccountManager

    init(
        appContext: AppContext,
        appReadiness: AppReadiness,
        backupAttachmentDownloadStore: BackupAttachmentDownloadStore,
        backupAttachmentUploadStore: BackupAttachmentUploadStore,
        backupSettingsStore: BackupSettingsStore,
        dateProvider: @escaping DateProvider,
        db: DB,
        deviceBatteryLevelManager: (any DeviceBatteryLevelManager)?,
        reachabilityManager: SSKReachabilityManager,
        remoteConfigManager: RemoteConfigManager,
        tsAccountManager: TSAccountManager
    ) {
        self.appContext = appContext
        self.appReadiness = appReadiness
        self.backupAttachmentDownloadStore = backupAttachmentDownloadStore
        self.backupAttachmentUploadStore = backupAttachmentUploadStore
        self.backupSettingsStore = backupSettingsStore
        self.dateProvider = dateProvider
        self.db = db
        self.deviceBatteryLevelManager = deviceBatteryLevelManager
        self.reachabilityManager = reachabilityManager
        self.remoteConfigManager = remoteConfigManager
        self.tsAccountManager = tsAccountManager

        self.state = State(isMainApp: appContext.isMainApp)

        appReadiness.runNowOrWhenMainAppDidBecomeReadyAsync { [weak self] in
            self?.appReadinessDidChange()
        }
    }

    // MARK: - Private

    private struct State {
        var isUploadQueueEmpty: Bool?
        var isDownloadQueueEmpty: Bool?
        var isMainApp: Bool
        var isAppReady = false
        var isRegistered: Bool?
        var areDownloadsSuspended: Bool?
        var shouldBackUpOnCellular: Bool?
        var isWifiReachable: Bool?
        // Value from 0 to 1
        var batteryLevel: Float?
        var isLowPowerMode: Bool?
        // Both in bytes
        var availableDiskSpace: UInt64?
        var requiredDiskSpace: UInt64?
        var downloadDidExperienceOutOfSpaceError = false

        func status(type: BackupAttachmentQueueType) -> BackupAttachmentQueueStatus {
            switch type {
            case .upload:
                if isUploadQueueEmpty == true {
                    return .empty
                }
            case .download:
                if isDownloadQueueEmpty == true {
                    return .empty
                }
            }

            guard
                isMainApp,
                isAppReady,
                isRegistered == true
            else {
                return .notRegisteredAndReady
            }

            switch type {
            case .download:
                if areDownloadsSuspended == true {
                    return .suspended
                }
            case .upload:
                break
            }

            if downloadDidExperienceOutOfSpaceError {
                return .lowDiskSpace
            }

            if
                type == .download,
                let availableDiskSpace,
                let requiredDiskSpace,
                availableDiskSpace < requiredDiskSpace
            {
                return .lowDiskSpace
            }

            let needsWifi: Bool
            switch type {
            case .upload:
                needsWifi = shouldBackUpOnCellular != true
            case .download:
                needsWifi = true
            }
            guard !needsWifi || isWifiReachable == true else {
                return .noWifiReachability
            }

            if let batteryLevel, batteryLevel < 0.1 {
                return .lowBattery
            }
            if isLowPowerMode == true {
                return .lowBattery
            }

            return .running
        }
    }

    private var state: State {
        didSet {
            for type in BackupAttachmentQueueType.allCases {
                if oldValue.status(type: type) != state.status(type: type) {
                    fireNotification(type: type)
                }
            }
        }
    }

    // MARK: State Observation

    private func observeDeviceAndLocalStatesIfNeeded() {
        let (isUploadQueueEmpty, isDownloadQueueEmpty, areDownloadsSuspended) = db.read { tx in
            return (
                ((try? backupAttachmentUploadStore.fetchNextUploads(count: 1, tx: tx)) ?? []).isEmpty,
                (try? backupAttachmentDownloadStore.hasAnyReadyDownloads(tx: tx))?.negated ?? true,
                backupAttachmentDownloadStore.isQueueSuspended(tx: tx)
            )

        }
        state.areDownloadsSuspended = areDownloadsSuspended
        defer {
            state.isUploadQueueEmpty = isUploadQueueEmpty
            state.isDownloadQueueEmpty = isDownloadQueueEmpty
        }
        // For change logic, treat nil as empty (if nil, observation is unstarted)
        let wasUploadQueueEmpty = state.isUploadQueueEmpty ?? true
        let wasDownloadQueueEmpty = state.isDownloadQueueEmpty ?? true

        let wereBothEmptyBefore = wasUploadQueueEmpty && wasDownloadQueueEmpty
        let areBothEmptyNow = isUploadQueueEmpty && isDownloadQueueEmpty

        if areBothEmptyNow, !wereBothEmptyBefore {
            // Stop observing all others
            stopObservingDeviceAndLocalStates()
        } else if !areBothEmptyNow, wereBothEmptyBefore {
            // Start observing all others.
            // We don't want to waste resources (in particular, tell
            // the OS we want battery level updates) unless we have to
            // so only observe if we have things in the queue.
            observeDeviceAndLocalStates()
        }
    }

    private func observeDeviceAndLocalStates() {
        let shouldBackUpOnCellular = db.read { tx in
            backupSettingsStore.shouldBackUpOnCellular(tx: tx)
        }

        let notificationsToObserve: [(NSNotification.Name, Selector)] = [
            (.registrationStateDidChange, #selector(registrationStateDidChange)),
            (BackupSettingsStore.Notifications.shouldBackUpOnCellularChanged, #selector(shouldBackUpOnCellularDidChange)),
            (.reachabilityChanged, #selector(reachabilityDidChange)),
            (UIDevice.batteryLevelDidChangeNotification, #selector(batteryLevelDidChange)),
            (Notification.Name.NSProcessInfoPowerStateDidChange, #selector(lowPowerModeDidChange)),
            (.OWSApplicationWillEnterForeground, #selector(willEnterForeground)),
            (.backupAttachmentDownloadQueueSuspensionStatusDidChange, #selector(suspensionStatusDidChange)),
        ]
        for (name, selector) in notificationsToObserve {
            NotificationCenter.default.addObserver(
                self,
                selector: selector,
                name: name,
                object: nil
            )
        }

        // Don't worry about this changing during an app lifetime; just check it once up front.
        let requiredDiskSpace = getRequiredDiskSpace()

        self.batteryLevelMonitor = deviceBatteryLevelManager?.beginMonitoring(reason: "BackupDownloadQueue")
        self.state = State(
            isUploadQueueEmpty: state.isUploadQueueEmpty,
            isDownloadQueueEmpty: state.isDownloadQueueEmpty,
            isMainApp: appContext.isMainApp,
            isAppReady: appReadiness.isAppReady,
            isRegistered: tsAccountManager.registrationStateWithMaybeSneakyTransaction.isRegistered,
            shouldBackUpOnCellular: shouldBackUpOnCellular,
            isWifiReachable: reachabilityManager.isReachable(via: .wifi),
            batteryLevel: batteryLevelMonitor?.batteryLevel,
            isLowPowerMode: deviceBatteryLevelManager?.isLowPowerModeEnabled,
            availableDiskSpace: getAvailableDiskSpace(),
            requiredDiskSpace: requiredDiskSpace
        )
    }

    private func stopObservingDeviceAndLocalStates() {
        NotificationCenter.default.removeObserver(self)
        batteryLevelMonitor.map { deviceBatteryLevelManager?.endMonitoring($0) }
    }

    // MARK: Per state changes

    private func appReadinessDidChange() {
        self.state.isAppReady = appReadiness.isAppReady
    }

    @objc
    private func registrationStateDidChange() {
        self.state.isRegistered = tsAccountManager.registrationStateWithMaybeSneakyTransaction.isRegistered
    }

    @objc
    private func shouldBackUpOnCellularDidChange() {
        state.shouldBackUpOnCellular = db.read { tx in
            backupSettingsStore.shouldBackUpOnCellular(tx: tx)
        }
    }

    @objc
    private func reachabilityDidChange() {
        self.state.isWifiReachable = reachabilityManager.isReachable(via: .wifi)
    }

    private var batteryLevelMonitor: DeviceBatteryLevelMonitor?

    @objc
    private func batteryLevelDidChange() {
        self.state.batteryLevel = batteryLevelMonitor?.batteryLevel
    }

    @objc
    private func lowPowerModeDidChange() {
        self.state.isLowPowerMode = deviceBatteryLevelManager?.isLowPowerModeEnabled
    }

    @objc
    private func suspensionStatusDidChange() {
        self.state.areDownloadsSuspended = db.read(block: backupAttachmentDownloadStore.isQueueSuspended(tx:))
    }

    private nonisolated func getAvailableDiskSpace() -> UInt64? {
        do {
            OWSFileSystem.ensureDirectoryExists(AttachmentStream.attachmentsDirectory().path)
            return try OWSFileSystem.freeSpaceInBytes(
                forPath: AttachmentStream.attachmentsDirectory()
            )
        } catch {
            owsFailDebug("Unable to determine disk space \(error)")
            return nil
        }
    }

    private nonisolated func getRequiredDiskSpace() -> UInt64 {
        return UInt64(remoteConfigManager.currentConfig().maxAttachmentDownloadSizeBytes) * 5
    }

    @objc
    private func availableDiskSpaceMaybeDidChange() {
        state.availableDiskSpace = getAvailableDiskSpace()
    }

    @objc
    private func willEnterForeground() {
        // Besides errors we get when writing downloaded attachment files to disk,
        // there isn't a good trigger for available disk space changes (and it
        // would be overkill to learn about every byte, anyway). Just check
        // when the app is foregrounded, so we can be proactive about stopping
        // downloads before we use up the last sliver of disk space.
        availableDiskSpaceMaybeDidChange()
    }

    private func downloadDidExperienceOutOfSpaceError() -> BackupAttachmentQueueStatus {
        state.downloadDidExperienceOutOfSpaceError = true
        return state.status(type: .download)
    }

    private func fireNotification(type: BackupAttachmentQueueType) {
        NotificationCenter.default.post(
            name: BackupAttachmentQueueStatus.didChangeNotification,
            object: nil,
            userInfo: [BackupAttachmentQueueStatus.notificationQueueTypeKey: type]
        )
    }
}
