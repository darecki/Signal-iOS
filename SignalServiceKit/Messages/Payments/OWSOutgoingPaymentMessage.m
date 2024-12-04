//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSOutgoingPaymentMessage.h"
#import <SignalServiceKit/NSDate+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@implementation OWSOutgoingPaymentMessage

- (instancetype)initWithThread:(TSThread *)thread
                   messageBody:(nullable NSString *)messageBody
           paymentNotification:(TSPaymentNotification *)paymentNotification
              expiresInSeconds:(uint32_t)expiresInSeconds
            expireTimerVersion:(nullable NSNumber *)expireTimerVersion
                   transaction:(SDSAnyReadTransaction *)transaction
{
    OWSAssertDebug(paymentNotification != nil);

    TSOutgoingMessageBuilder *messageBuilder = [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:thread];
    // Body ranges unsupported.
    messageBuilder.messageBody = messageBody;
    messageBuilder.isViewOnceMessage = false;
    messageBuilder.expiresInSeconds = expiresInSeconds;
    messageBuilder.expireTimerVersion = expireTimerVersion;
    self = [super initOutgoingMessageWithBuilder:messageBuilder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];
    if (!self) {
        return self;
    }

    _paymentNotification = paymentNotification;

    return self;
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
                groupMetaMessage:(TSGroupMetaMessage)groupMetaMessage
           hasLegacyMessageState:(BOOL)hasLegacyMessageState
             hasSyncedTranscript:(BOOL)hasSyncedTranscript
                  isVoiceMessage:(BOOL)isVoiceMessage
              legacyMessageState:(TSOutgoingMessageState)legacyMessageState
              legacyWasDelivered:(BOOL)legacyWasDelivered
           mostRecentFailureText:(nullable NSString *)mostRecentFailureText
          recipientAddressStates:(nullable NSDictionary<SignalServiceAddress *,TSOutgoingMessageRecipientState *> *)recipientAddressStates
              storedMessageState:(TSOutgoingMessageState)storedMessageState
            wasNotCreatedLocally:(BOOL)wasNotCreatedLocally
             paymentCancellation:(nullable NSData *)paymentCancellation
             paymentNotification:(nullable TSPaymentNotification *)paymentNotification
                  paymentRequest:(nullable NSData *)paymentRequest
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
                  groupMetaMessage:groupMetaMessage
             hasLegacyMessageState:hasLegacyMessageState
               hasSyncedTranscript:hasSyncedTranscript
                    isVoiceMessage:isVoiceMessage
                legacyMessageState:legacyMessageState
                legacyWasDelivered:legacyWasDelivered
             mostRecentFailureText:mostRecentFailureText
            recipientAddressStates:recipientAddressStates
                storedMessageState:storedMessageState
              wasNotCreatedLocally:wasNotCreatedLocally];

    if (!self) {
        return self;
    }

    _paymentCancellation = paymentCancellation;
    _paymentNotification = paymentNotification;
    _paymentRequest = paymentRequest;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

// These are the things driving messages in chat; unlike for
// a normal text message's TSOutgoingMessage which is transient
// only needed for sending, and has a corresponding TSMessage
// that drives UI.
- (BOOL)shouldBeSaved
{
    return YES;
}

- (BOOL)hasRenderableContent
{
    return YES;
}

- (nullable SSKProtoDataMessageBuilder *)dataMessageBuilderWithThread:(TSThread *)thread
                                                          transaction:(SDSAnyReadTransaction *)transaction
{
    if (self.paymentNotification == nil) {
        OWSFailDebug(@"Missing payload.");
        return nil;
    }

    SSKProtoDataMessageBuilder *builder = [super dataMessageBuilderWithThread:thread transaction:transaction];
    [builder setTimestamp:self.timestamp];

    NSError *error;
    BOOL success = [self.paymentNotification addToDataBuilder:builder error:&error];
    if (error || !success) {
        OWSFailDebug(@"Could not build paymentNotification proto: %@.", error);
    }

    [builder setExpireTimer:self.expiresInSeconds];
    if (self.expireTimerVersion) {
        [builder setExpireTimerVersion:[self.expireTimerVersion unsignedIntValue]];
    } else {
        [builder setExpireTimerVersion:0];
    }

    [builder setRequiredProtocolVersion:(uint32_t)SSKProtoDataMessageProtocolVersionPayments];
    return builder;
}

@end

NS_ASSUME_NONNULL_END
