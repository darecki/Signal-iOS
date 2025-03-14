//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/BaseModel.h>

NS_ASSUME_NONNULL_BEGIN

@class DBReadTransaction;
@class TSThread;

@interface OWSDisappearingMessagesConfiguration : BaseModel

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithUniqueId:(NSString *)uniqueId NS_UNAVAILABLE;
- (instancetype)initWithGrdbId:(int64_t)grdbId uniqueId:(NSString *)uniqueId NS_UNAVAILABLE;

// This initializer should only be used internally.
- (instancetype)initWithThreadId:(NSString *)threadId
                         enabled:(BOOL)isEnabled
                 durationSeconds:(uint32_t)seconds
                    timerVersion:(uint32_t)timerVersion NS_DESIGNATED_INITIALIZER;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
                 durationSeconds:(unsigned int)durationSeconds
                         enabled:(BOOL)enabled
                    timerVersion:(unsigned int)timerVersion
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:durationSeconds:enabled:timerVersion:));

// clang-format on

// --- CODE GENERATION MARKER

@property (nonatomic, readonly, getter=isEnabled) BOOL enabled;
@property (nonatomic, readonly) uint32_t durationSeconds;
@property (nonatomic, readonly) NSString *durationString;
@property (nonatomic, readonly) uint32_t timerVersion;

+ (NSArray<NSNumber *> *)presetDurationsSeconds;
+ (uint32_t)maxDurationSeconds;

// It's critical that we only modify copies.
// Otherwise any modifications will be made to the
// instance in the YDB object cache and hasChangedForThread:
// won't be able to detect changes.
- (instancetype)copyWithIsEnabled:(BOOL)isEnabled timerVersion:(uint32_t)timerVersion;
- (instancetype)copyWithDurationSeconds:(uint32_t)durationSeconds timerVersion:(uint32_t)timerVersion;
- (instancetype)copyAsEnabledWithDurationSeconds:(uint32_t)durationSeconds timerVersion:(uint32_t)timerVersion;

@end

NS_ASSUME_NONNULL_END
