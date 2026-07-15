//
//  TurboAdLogger.m
//  TurboAdSDK
//

#import "TurboAdLogger.h"

@implementation TurboAdLogger

+ (instancetype)sharedLogger {
    static TurboAdLogger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _logLevel = TurboAdLogLevelWarning;
    }
    return self;
}

- (void)logError:(NSString *)format, ... {
    if (self.logLevel < TurboAdLogLevelError) return;
    va_list args;
    va_start(args, format);
    [self logWithLevel:@"ERROR" format:format args:args];
    va_end(args);
}

- (void)logWarning:(NSString *)format, ... {
    if (self.logLevel < TurboAdLogLevelWarning) return;
    va_list args;
    va_start(args, format);
    [self logWithLevel:@"WARN" format:format args:args];
    va_end(args);
}

- (void)logInfo:(NSString *)format, ... {
    if (self.logLevel < TurboAdLogLevelInfo) return;
    va_list args;
    va_start(args, format);
    [self logWithLevel:@"INFO" format:format args:args];
    va_end(args);
}

- (void)logDebug:(NSString *)format, ... {
    if (self.logLevel < TurboAdLogLevelDebug) return;
    va_list args;
    va_start(args, format);
    [self logWithLevel:@"DEBUG" format:format args:args];
    va_end(args);
}

- (void)logVerbose:(NSString *)format, ... {
    if (self.logLevel < TurboAdLogLevelVerbose) return;
    va_list args;
    va_start(args, format);
    [self logWithLevel:@"VERBOSE" format:format args:args];
    va_end(args);
}

- (void)logWithLevel:(NSString *)level format:(NSString *)format args:(va_list)args {
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    NSLog(@"[TurboAdSDK][%@][%@] %@", timestamp, level, message);
}

@end
