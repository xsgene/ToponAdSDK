//
//  TurboAdSDKCore.m
//  TurboAdSDK
//

#import "TurboAdSDKCore.h"
#import "TurboAdConstants.h"
#import "TurboAdLogger.h"
#import "TurboAdStorage.h"
#import "TurboAdUtils.h"
#import "TurboAdNetworking.h"

@interface TurboAdSDKCore ()
@property (nonatomic, assign, readwrite, getter=isInitialized) BOOL initialized;
@property (nonatomic, strong, readwrite, nullable) TurboAdSDKConfig *config;
@property (nonatomic, copy, readwrite) NSString *deviceID;
@end

@implementation TurboAdSDKCore

+ (instancetype)sharedCore {
    static TurboAdSDKCore *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _initialized = NO;
        _deviceID = [self loadOrCreateDeviceID];
    }
    return self;
}

- (void)initializeWithConfig:(TurboAdSDKConfig *)config completion:(TurboAdSDKInitCompletion)completion {
    if (!config || [TurboAdUtils isEmptyString:config.appID] || [TurboAdUtils isEmptyString:config.appKey]) {
        NSError *error = [NSError errorWithDomain:kTurboAdErrorDomain
                                             code:TurboAdErrorCodeInvalidConfiguration
                                         userInfo:@{NSLocalizedDescriptionKey: @"App ID and App Key are required"}];
        TurboLogError(@"SDK initialization failed: invalid configuration");
        if (completion) {
            completion(NO, error);
        }
        return;
    }
    
    // 设置日志级别
    [TurboAdLogger sharedLogger].logLevel = config.logLevel;
    
    self.config = config;
    
    // 保存 App ID
    [[TurboAdStorage sharedStorage] setObject:config.appID forKey:kTurboAdStorageKeyAppID];
    
    TurboLogInfo(@"TurboAdSDK v%@ initializing...", [self sdkVersion]);
    TurboLogInfo(@"App ID: %@", config.appID);
    
    // 请求服务器配置
    [self requestAppSettingWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            self.initialized = YES;
            TurboLogInfo(@"TurboAdSDK initialized successfully");
            
            // 发送初始化成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kTurboAdNotificationSDKDidInitialize
                                                                object:nil
                                                              userInfo:@{@"success": @YES}];
        } else {
            TurboLogError(@"TurboAdSDK initialization failed: %@", error.localizedDescription);
        }
        
        if (completion) {
            completion(success, error);
        }
    }];
}

- (NSString *)sdkVersion {
    return kTurboAdSDKVersion;
}

- (BOOL)checkInitialized {
    if (!self.isInitialized) {
        TurboLogError(@"TurboAdSDK has not been initialized. Please call initializeWithConfig: first.");
        return NO;
    }
    return YES;
}

#pragma mark - Private

- (void)requestAppSettingWithCompletion:(void(^)(BOOL success, NSError *error))completion {
    NSString *baseURL = self.config.serverURL ?: @"https://api.turboadsdk.com";
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/app/setting", baseURL];
    
    NSDictionary *params = @{
        @"app_id": self.config.appID ?: @"",
        @"device_id": self.deviceID ?: @"",
        @"platform": @"ios",
        @"sdk_version": [self sdkVersion],
        @"app_version": [TurboAdUtils appVersion] ?: @"",
        @"device_model": [TurboAdUtils deviceModel] ?: @"",
        @"os_version": [TurboAdUtils systemVersion] ?: @""
    };
    
    [[TurboAdNetworking sharedManager] GET:urlString
                                parameters:params
                                   headers:nil
                                completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            // 网络错误时，仍然允许 SDK 使用本地缓存或默认配置初始化
            TurboLogWarning(@"Failed to fetch app setting, using local cache: %@", error.localizedDescription);
            if (completion) completion(YES, nil);
            return;
        }
        
        if (data) {
            NSError *jsonError = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError && responseDict) {
                TurboLogDebug(@"App setting received: %@", responseDict);
                // 缓存配置
                [[TurboAdStorage sharedStorage] setObject:responseDict forKey:@"turbo_ad_app_setting"];
            }
        }
        
        if (completion) completion(YES, nil);
    }];
}

- (NSString *)loadOrCreateDeviceID {
    NSString *deviceID = [[TurboAdStorage sharedStorage] objectForKey:kTurboAdStorageKeyDeviceID];
    if (!deviceID) {
        deviceID = [TurboAdUtils generateUUID];
        [[TurboAdStorage sharedStorage] setObject:deviceID forKey:kTurboAdStorageKeyDeviceID];
    }
    return deviceID;
}

@end
