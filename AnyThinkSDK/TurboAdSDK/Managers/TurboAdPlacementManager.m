//
//  TurboAdPlacementManager.m
//  TurboAdSDK
//

#import "TurboAdPlacementManager.h"
#import "TurboAdPlacementModel.h"
#import "TurboAdSDKCore.h"
#import "TurboAdNetworking.h"
#import "TurboAdStorage.h"
#import "TurboAdLogger.h"
#import "TurboAdUtils.h"
#import "TurboAdThreadSafe.h"
#import "TurboAdConstants.h"

@interface TurboAdPlacementManager ()
@property (nonatomic, strong) TurboAdThreadSafeDictionary *cache; // placementID -> TurboAdPlacementModel
@end

@implementation TurboAdPlacementManager

+ (instancetype)sharedManager {
    static TurboAdPlacementManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[TurboAdThreadSafeDictionary alloc] initWithQueueLabel:@"com.turboadsdk.placement.cache"];
    }
    return self;
}

- (void)fetchPlacementSettingWithPlacementID:(NSString *)placementID
                                       extra:(NSDictionary *)extra
                                  completion:(void(^)(TurboAdPlacementModel *model, NSError *error))completion {
    
    // 先检查缓存
    TurboAdPlacementModel *cached = [self cachedPlacementModelWithPlacementID:placementID];
    if (cached) {
        TurboLogDebug(@"Using cached placement model for: %@", placementID);
        if (completion) completion(cached, nil);
    }
    
    // 请求服务器
    TurboAdSDKCore *core = [TurboAdSDKCore sharedCore];
    NSString *baseURL = core.config.serverURL ?: @"https://api.turboadsdk.com";
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/placement/setting", baseURL];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"placement_id"] = placementID;
    params[@"app_id"] = core.config.appID ?: @"";
    params[@"device_id"] = core.deviceID ?: @"";
    params[@"platform"] = @"ios";
    params[@"sdk_version"] = [core sdkVersion];
    if (extra) {
        [params addEntriesFromDictionary:extra];
    }
    
    [[TurboAdNetworking sharedManager] GET:urlString
                                parameters:params
                                   headers:nil
                                completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            TurboLogError(@"Failed to fetch placement setting: %@", error.localizedDescription);
            // 如果有缓存，仍然返回成功
            if (cached) {
                if (completion) completion(cached, nil);
            } else {
                if (completion) completion(nil, error);
            }
            return;
        }
        
        if (data) {
            NSError *jsonError = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonError && responseDict) {
                NSDictionary *placementDict = responseDict[@"placement"];
                if ([placementDict isKindOfClass:[NSDictionary class]]) {
                    TurboAdPlacementModel *model = [TurboAdPlacementModel modelWithDictionary:placementDict];
                    if (model) {
                        // 缓存配置
                        [self.cache setObject:model forKey:placementID];
                        TurboLogDebug(@"Placement setting fetched for: %@", placementID);
                        if (completion) completion(model, nil);
                        return;
                    }
                }
            }
        }
        
        // 解析失败，尝试使用缓存
        if (cached) {
            if (completion) completion(cached, nil);
        } else {
            NSError *parseError = [NSError errorWithDomain:kTurboAdErrorDomain
                                                      code:TurboAdErrorCodeParseError
                                                  userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse placement setting"}];
            if (completion) completion(nil, parseError);
        }
    }];
}

- (TurboAdPlacementModel *)cachedPlacementModelWithPlacementID:(NSString *)placementID {
    return [self.cache objectForKey:placementID];
}

- (void)clearCache {
    [self.cache removeAllObjects];
    TurboLogInfo(@"Placement cache cleared");
}

@end
