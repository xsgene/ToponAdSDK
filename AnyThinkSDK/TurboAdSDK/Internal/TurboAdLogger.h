//
//  TurboAdLogger.h
//  TurboAdSDK
//
//  Created by TurboAdSDK on 2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TurboAdLogLevel) {
    TurboAdLogLevelNone = 0,
    TurboAdLogLevelError,
    TurboAdLogLevelWarning,
    TurboAdLogLevelInfo,
    TurboAdLogLevelDebug,
    TurboAdLogLevelVerbose
};

@interface TurboAdLogger : NSObject

@property (nonatomic, assign) TurboAdLogLevel logLevel;

+ (instancetype)sharedLogger;

- (void)logError:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)logWarning:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)logInfo:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)logDebug:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)logVerbose:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end

#define TurboLogError(fmt, ...)   [[TurboAdLogger sharedLogger] logError:fmt, ##__VA_ARGS__]
#define TurboLogWarning(fmt, ...) [[TurboAdLogger sharedLogger] logWarning:fmt, ##__VA_ARGS__]
#define TurboLogInfo(fmt, ...)    [[TurboAdLogger sharedLogger] logInfo:fmt, ##__VA_ARGS__]
#define TurboLogDebug(fmt, ...)   [[TurboAdLogger sharedLogger] logDebug:fmt, ##__VA_ARGS__]
#define TurboLogVerbose(fmt, ...) [[TurboAdLogger sharedLogger] logVerbose:fmt, ##__VA_ARGS__]

NS_ASSUME_NONNULL_END
