//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

public import LibSignalClient
public import GRDB

@objc
public class DBReadTransaction: NSObject {
    public let database: Database
    public let startDate: Date

    init(database: Database) {
        self.database = database
        self.startDate = Date()
    }
}

@objc
public class DBWriteTransaction: DBReadTransaction, LibSignalClient.StoreContext {
    private enum TransactionState {
        case open
        case finalizing
        case finalized
    }

    typealias FinalizationBlock = (DBWriteTransaction) -> Void
    typealias SyncCompletion = () -> Void
    struct AsyncCompletion {
        let scheduler: Scheduler
        let block: () -> Void
    }

    private var transactionState: TransactionState
    private var finalizationBlocks: [String: FinalizationBlock]
    private(set) var syncCompletions: [SyncCompletion]
    private(set) var asyncCompletions: [AsyncCompletion]

    override init(database: Database) {
        self.transactionState = .open
        self.finalizationBlocks = [:]
        self.syncCompletions = []
        self.asyncCompletions = []

        super.init(database: database)
    }

    deinit {
        owsAssertDebug(
            transactionState == .finalized,
            "Write transaction deallocated without finalization!"
        )
    }

    // MARK: -

    func finalizeTransaction() {
        guard transactionState == .open else {
            owsFailDebug("Write transaction finalized multiple times!")
            return
        }

        transactionState = .finalizing

        for (_, finalizationBlock) in finalizationBlocks {
            finalizationBlock(self)
        }

        finalizationBlocks.removeAll()
        transactionState = .finalized
    }

    // MARK: -

    /// Schedule the given block to run when this transaction is finalized.
    ///
    /// - Important
    /// `block` must not capture any database models, as they may no longer be
    /// valid by time the transaction finalizes.
    func addFinalizationBlock(key: String, block: @escaping FinalizationBlock) {
        finalizationBlocks[key] = block
    }

    /// Run the given block synchronously after the transaction is finalized.
    public func addSyncCompletion(_ block: @escaping () -> Void) {
        syncCompletions.append(block)
    }

    /// Schedule the given block to run on `scheduler` after the transaction is
    /// finalized.
    public func addAsyncCompletion(on scheduler: Scheduler, block: @escaping () -> Void) {
        asyncCompletions.append(AsyncCompletion(scheduler: scheduler, block: block))
    }
}

// MARK: -

public extension LibSignalClient.StoreContext {
    var asTransaction: DBWriteTransaction {
        return self as! DBWriteTransaction
    }
}
