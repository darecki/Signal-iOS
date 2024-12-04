//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSVerificationStateChangeMessage.h"
#import "OWSDisappearingMessagesConfiguration.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@implementation OWSVerificationStateChangeMessage

- (instancetype)initWithThread:(TSThread *)thread
                     timestamp:(uint64_t)timestamp
              recipientAddress:(SignalServiceAddress *)recipientAddress
             verificationState:(OWSVerificationState)verificationState
                 isLocalChange:(BOOL)isLocalChange
{
    OWSAssertDebug(recipientAddress.isValid);

    self = [super initWithThread:thread
                       timestamp:timestamp
                      serverGuid:nil
                     messageType:TSInfoMessageVerificationStateChange
             infoMessageUserInfo:nil];
    if (!self) {
        return self;
    }

    _recipientAddress = recipientAddress;
    _verificationState = verificationState;
    _isLocalChange = isLocalChange;

    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        if (_recipientAddress == nil) {
            NSString *_Nullable phoneNumber = [coder decodeObjectForKey:@"recipientId"];
            _recipientAddress = [SignalServiceAddress legacyAddressWithServiceIdString:nil phoneNumber:phoneNumber];
            OWSAssertDebug(_recipientAddress.isValid);
        }
    }
    return self;
}

- (bool)isVerified
{
    return _verificationState == OWSVerificationStateVerified;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          sortId:(uint64_t)sortId
                       timestamp:(uint64_t)timestamp
                  uniqueThreadId:(NSString *)uniqueThreadId
                            body:(nullable NSString *)body
                      bodyRanges:(nullable MessageBodyRanges *)bodyRanges
                    contactShare:(nullable OWSContact *)contactShare
        deprecated_attachmentIds:(nullable NSArray<NSString *> *)deprecated_attachmentIds
                       editState:(TSEditState)editState
                 expireStartedAt:(uint64_t)expireStartedAt
              expireTimerVersion:(nullable NSNumber *)expireTimerVersion
                       expiresAt:(uint64_t)expiresAt
                expiresInSeconds:(unsigned int)expiresInSeconds
                       giftBadge:(nullable OWSGiftBadge *)giftBadge
               isGroupStoryReply:(BOOL)isGroupStoryReply
  isSmsMessageRestoredFromBackup:(BOOL)isSmsMessageRestoredFromBackup
              isViewOnceComplete:(BOOL)isViewOnceComplete
               isViewOnceMessage:(BOOL)isViewOnceMessage
                     linkPreview:(nullable OWSLinkPreview *)linkPreview
                  messageSticker:(nullable MessageSticker *)messageSticker
                   quotedMessage:(nullable TSQuotedMessage *)quotedMessage
    storedShouldStartExpireTimer:(BOOL)storedShouldStartExpireTimer
           storyAuthorUuidString:(nullable NSString *)storyAuthorUuidString
              storyReactionEmoji:(nullable NSString *)storyReactionEmoji
                  storyTimestamp:(nullable NSNumber *)storyTimestamp
              wasRemotelyDeleted:(BOOL)wasRemotelyDeleted
                   customMessage:(nullable NSString *)customMessage
             infoMessageUserInfo:(nullable NSDictionary<InfoMessageUserInfoKey, id> *)infoMessageUserInfo
                     messageType:(TSInfoMessageType)messageType
                            read:(BOOL)read
                      serverGuid:(nullable NSString *)serverGuid
             unregisteredAddress:(nullable SignalServiceAddress *)unregisteredAddress
                   isLocalChange:(BOOL)isLocalChange
                recipientAddress:(SignalServiceAddress *)recipientAddress
               verificationState:(OWSVerificationState)verificationState
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId
               receivedAtTimestamp:receivedAtTimestamp
                            sortId:sortId
                         timestamp:timestamp
                    uniqueThreadId:uniqueThreadId
                              body:body
                        bodyRanges:bodyRanges
                      contactShare:contactShare
          deprecated_attachmentIds:deprecated_attachmentIds
                         editState:editState
                   expireStartedAt:expireStartedAt
                expireTimerVersion:expireTimerVersion
                         expiresAt:expiresAt
                  expiresInSeconds:expiresInSeconds
                         giftBadge:giftBadge
                 isGroupStoryReply:isGroupStoryReply
    isSmsMessageRestoredFromBackup:isSmsMessageRestoredFromBackup
                isViewOnceComplete:isViewOnceComplete
                 isViewOnceMessage:isViewOnceMessage
                       linkPreview:linkPreview
                    messageSticker:messageSticker
                     quotedMessage:quotedMessage
      storedShouldStartExpireTimer:storedShouldStartExpireTimer
             storyAuthorUuidString:storyAuthorUuidString
                storyReactionEmoji:storyReactionEmoji
                    storyTimestamp:storyTimestamp
                wasRemotelyDeleted:wasRemotelyDeleted
                     customMessage:customMessage
               infoMessageUserInfo:infoMessageUserInfo
                       messageType:messageType
                              read:read
                        serverGuid:serverGuid
               unregisteredAddress:unregisteredAddress];

    if (!self) {
        return self;
    }

    _isLocalChange = isLocalChange;
    _recipientAddress = recipientAddress;
    _verificationState = verificationState;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

@end

NS_ASSUME_NONNULL_END
