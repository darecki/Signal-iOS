//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import GRDB

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Typed Convenience Methods

@objc
public extension TSInfoMessage {
    // NOTE: This method will fail if the object has unexpected type.
    class func anyFetchInfoMessage(
        uniqueId: String,
        transaction: DBReadTransaction
    ) -> TSInfoMessage? {
        assert(!uniqueId.isEmpty)

        guard let object = anyFetch(uniqueId: uniqueId,
                                    transaction: transaction) else {
                                        return nil
        }
        guard let instance = object as? TSInfoMessage else {
            owsFailDebug("Object has unexpected type: \(type(of: object))")
            return nil
        }
        return instance
    }

    // NOTE: This method will fail if the object has unexpected type.
    func anyUpdateInfoMessage(transaction: DBWriteTransaction, block: (TSInfoMessage) -> Void) {
        anyUpdate(transaction: transaction) { (object) in
            guard let instance = object as? TSInfoMessage else {
                owsFailDebug("Object has unexpected type: \(type(of: object))")
                return
            }
            block(instance)
        }
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class TSInfoMessageSerializer: SDSSerializer {

    private let model: TSInfoMessage
    public init(model: TSInfoMessage) {
        self.model = model
    }

    // MARK: - Record

    func asRecord() -> SDSRecord {
        let id: Int64? = model.sortId > 0 ? Int64(model.sortId) : model.grdbId?.int64Value

        let recordType: SDSRecordType = .infoMessage
        let uniqueId: String = model.uniqueId

        // Properties
        let receivedAtTimestamp: UInt64 = model.receivedAtTimestamp
        let timestamp: UInt64 = model.timestamp
        let threadUniqueId: String = model.uniqueThreadId
        let deprecated_attachmentIds: Data? = optionalArchive(model.deprecated_attachmentIds)
        let authorId: String? = nil
        let authorPhoneNumber: String? = nil
        let authorUUID: String? = nil
        let body: String? = model.body
        let callType: RPRecentCallType? = nil
        let configurationDurationSeconds: UInt32? = nil
        let configurationIsEnabled: Bool? = nil
        let contactShare: Data? = optionalArchive(model.contactShare)
        let createdByRemoteName: String? = nil
        let createdInExistingGroup: Bool? = nil
        let customMessage: String? = model.customMessage
        let envelopeData: Data? = nil
        let errorType: TSErrorMessageType? = nil
        let expireStartedAt: UInt64? = model.expireStartedAt
        let expiresAt: UInt64? = model.expiresAt
        let expiresInSeconds: UInt32? = model.expiresInSeconds
        let groupMetaMessage: TSGroupMetaMessage? = nil
        let hasLegacyMessageState: Bool? = nil
        let hasSyncedTranscript: Bool? = nil
        let wasNotCreatedLocally: Bool? = nil
        let isLocalChange: Bool? = nil
        let isViewOnceComplete: Bool? = model.isViewOnceComplete
        let isViewOnceMessage: Bool? = model.isViewOnceMessage
        let isVoiceMessage: Bool? = nil
        let legacyMessageState: TSOutgoingMessageState? = nil
        let legacyWasDelivered: Bool? = nil
        let linkPreview: Data? = optionalArchive(model.linkPreview)
        let messageId: String? = nil
        let messageSticker: Data? = optionalArchive(model.messageSticker)
        let messageType: TSInfoMessageType? = model.messageType
        let mostRecentFailureText: String? = nil
        let preKeyBundle: Data? = nil
        let protocolVersion: UInt? = nil
        let quotedMessage: Data? = optionalArchive(model.quotedMessage)
        let read: Bool? = model.wasRead
        let recipientAddress: Data? = nil
        let recipientAddressStates: Data? = nil
        let sender: Data? = nil
        let serverTimestamp: UInt64? = nil
        let deprecated_sourceDeviceId: UInt32? = nil
        let storedMessageState: TSOutgoingMessageState? = nil
        let storedShouldStartExpireTimer: Bool? = model.storedShouldStartExpireTimer
        let unregisteredAddress: Data? = optionalArchive(model.unregisteredAddress)
        let verificationState: OWSVerificationState? = nil
        let wasReceivedByUD: Bool? = nil
        let infoMessageUserInfo: Data? = optionalArchive(model.infoMessageUserInfo)
        let wasRemotelyDeleted: Bool? = model.wasRemotelyDeleted
        let bodyRanges: Data? = optionalArchive(model.bodyRanges)
        let offerType: TSRecentCallOfferType? = nil
        let serverDeliveryTimestamp: UInt64? = nil
        let eraId: String? = nil
        let hasEnded: Bool? = nil
        let creatorUuid: String? = nil
        let joinedMemberUuids: Data? = nil
        let wasIdentityVerified: Bool? = nil
        let paymentCancellation: Data? = nil
        let paymentNotification: Data? = nil
        let paymentRequest: Data? = nil
        let viewed: Bool? = nil
        let serverGuid: String? = model.serverGuid
        let storyAuthorUuidString: String? = model.storyAuthorUuidString
        let storyTimestamp: UInt64? = archiveOptionalNSNumber(model.storyTimestamp, conversion: { $0.uint64Value })
        let isGroupStoryReply: Bool? = model.isGroupStoryReply
        let storyReactionEmoji: String? = model.storyReactionEmoji
        let giftBadge: Data? = optionalArchive(model.giftBadge)
        let editState: TSEditState? = model.editState
        let archivedPaymentInfo: Data? = nil
        let expireTimerVersion: UInt32? = archiveOptionalNSNumber(model.expireTimerVersion, conversion: { $0.uint32Value })
        let isSmsMessageRestoredFromBackup: Bool? = model.isSmsMessageRestoredFromBackup

        return InteractionRecord(delegate: model, id: id, recordType: recordType, uniqueId: uniqueId, receivedAtTimestamp: receivedAtTimestamp, timestamp: timestamp, threadUniqueId: threadUniqueId, deprecated_attachmentIds: deprecated_attachmentIds, authorId: authorId, authorPhoneNumber: authorPhoneNumber, authorUUID: authorUUID, body: body, callType: callType, configurationDurationSeconds: configurationDurationSeconds, configurationIsEnabled: configurationIsEnabled, contactShare: contactShare, createdByRemoteName: createdByRemoteName, createdInExistingGroup: createdInExistingGroup, customMessage: customMessage, envelopeData: envelopeData, errorType: errorType, expireStartedAt: expireStartedAt, expiresAt: expiresAt, expiresInSeconds: expiresInSeconds, groupMetaMessage: groupMetaMessage, hasLegacyMessageState: hasLegacyMessageState, hasSyncedTranscript: hasSyncedTranscript, wasNotCreatedLocally: wasNotCreatedLocally, isLocalChange: isLocalChange, isViewOnceComplete: isViewOnceComplete, isViewOnceMessage: isViewOnceMessage, isVoiceMessage: isVoiceMessage, legacyMessageState: legacyMessageState, legacyWasDelivered: legacyWasDelivered, linkPreview: linkPreview, messageId: messageId, messageSticker: messageSticker, messageType: messageType, mostRecentFailureText: mostRecentFailureText, preKeyBundle: preKeyBundle, protocolVersion: protocolVersion, quotedMessage: quotedMessage, read: read, recipientAddress: recipientAddress, recipientAddressStates: recipientAddressStates, sender: sender, serverTimestamp: serverTimestamp, deprecated_sourceDeviceId: deprecated_sourceDeviceId, storedMessageState: storedMessageState, storedShouldStartExpireTimer: storedShouldStartExpireTimer, unregisteredAddress: unregisteredAddress, verificationState: verificationState, wasReceivedByUD: wasReceivedByUD, infoMessageUserInfo: infoMessageUserInfo, wasRemotelyDeleted: wasRemotelyDeleted, bodyRanges: bodyRanges, offerType: offerType, serverDeliveryTimestamp: serverDeliveryTimestamp, eraId: eraId, hasEnded: hasEnded, creatorUuid: creatorUuid, joinedMemberUuids: joinedMemberUuids, wasIdentityVerified: wasIdentityVerified, paymentCancellation: paymentCancellation, paymentNotification: paymentNotification, paymentRequest: paymentRequest, viewed: viewed, serverGuid: serverGuid, storyAuthorUuidString: storyAuthorUuidString, storyTimestamp: storyTimestamp, isGroupStoryReply: isGroupStoryReply, storyReactionEmoji: storyReactionEmoji, giftBadge: giftBadge, editState: editState, archivedPaymentInfo: archivedPaymentInfo, expireTimerVersion: expireTimerVersion, isSmsMessageRestoredFromBackup: isSmsMessageRestoredFromBackup)
    }
}
