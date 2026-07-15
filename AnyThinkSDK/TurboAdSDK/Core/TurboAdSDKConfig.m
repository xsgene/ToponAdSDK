//
//  TurboAdSDKConfig.m
//  TurboAdSDK
//

#import "TurboAdSDKConfig.h"

@implementation TurboAdSDKConfig

+ (instancetype)configWithAppID:(NSString *)appID appKey:(NSString *)appKey {
    TurboAdSDKConfig *config = [[TurboAdSDKConfig alloc] init];
    config.appID = appID;
    config.appKey = appKey;
    config.logLevel = TurboAdLogLevelWarning;
    config.testMode = NO;
    return config;
}

@end
