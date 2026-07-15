//
//  TurboAdManager.m
//  TurboAdSDK
//

#import "TurboAdManager.h"
#import "TurboAdSDKCore.h"
#import "TurboAdConstants.h"
#import "TurboAdLoader.h"
#import "TurboAdLogger.h"
#import "TurboAdPlacementManager.h"
#import "TurboAdCapsManager.h"
#import "TurboAdTracker.h"
#import "TurboAdThreadSafe.h"
#import "TurboAdObject.h"
#import "TurboAdPlacementModel.h"

@interface TurboAdManager ()
@property (nonatomic, strong) TurboAdLoader *loader;
@property (nonatomic, strong) TurboAdThreadSafeDictionary *loadingDelegates;  // placementID -> delegate
@property (nonatomic, strong) TurboAdThreadSafeDictionary *adStorages;        // placementID -> [TurboAdObject]
@property (nonatomic, strong) TurboAdThreadSafeDictionary *loadingStatus;     // placementID -> @(BOOL)
@end

@implementation TurboAdManager

+ (instancetype)sharedManager {
    static TurboAdManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _loader = [[TurboAdLoader alloc] init];
        _loadingDelegates = [[TurboAdThreadSafeDictionary alloc] initWithQueueLabel:@"com.turboadsdk.manager.delegates"];
        _adStorages = [[TurboAdThreadSafeDictionary alloc] initWithQueueLabel:@"com.turboadsdk.manager.storages"];
        _loadingStatus = [[TurboAdThreadSafeDictionary alloc] initWithQueueLabel:@"com.turboadsdk.manager.loading"];
    }
    return self;
}

- (void)loadADWithPlacementID:(NSString *)placementID
                        extra:(NSDictionary *)extra
                     delegate:(id<TurboAdLoadingDelegate>)delegate {
    
    if (![[TurboAdSDKCore sharedCore] checkInitialized]) {
        NSError *error = [NSError errorWithDomain:kTurboAdErrorDomain
                                             code:TurboAdErrorCodeSDKNotInitialized
                                         userInfo:@{NSLocalizedDescriptionKey: @"SDK not initialized"}];
        [TurboAdUtils runOnMainThread:^{
            if ([delegate respondsToSelector:@selector(didFailToLoadAdWithPlacementID:error:)]) {
                [delegate didFailToLoadAdWithPlacementID:placementID error:error];
            }
        }];
        return;
    }
    
    if ([TurboAdUtils isEmptyString:placementID]) {
        NSError *error = [NSError errorWithDomain:kTurboAdErrorDomain
                                             code:TurboAdErrorCodeInvalidConfiguration
                                         userInfo:@{NSLocalizedDescriptionKey: @"Placement ID is empty"}];
        [TurboAdUtils runOnMainThread:^{
            if ([delegate respondsToSelector:@selector(didFailToLoadAdWithPlacementID:error:)]) {
                [delegate didFailToLoadAdWithPlacementID:placementID error:error];
            }
        }];
        return;
    }
    
    // 检查频控
    if (![[TurboAdCapsManager sharedManager] canLoadWithPlacementID:placementID]) {
        NSError *error = [NSError errorWithDomain:kTurboAdErrorDomain
                                             code:TurboAdErrorCodeFrequencyLimited
                                         userInfo:@{NSLocalizedDescriptionKey: @"Load frequency limited"}];
        [TurboAdUtils runOnMainThread:^{
            if ([delegate respondsToSelector:@selector(didFailToLoadAdWithPlacementID:error:)]) {
                [delegate didFailToLoadAdWithPlacementID:placementID error:error];
            }
        }];
        return;
    }
    
    // 保存 delegate
    [self.loadingDelegates setObject:delegate forKey:placementID];
    [self.loadingStatus setObject:@(YES) forKey:placementID];
    
    // 合并 extra
    NSMutableDictionary *mergedExtra = [NSMutableDictionary dictionary];
    if (self.extra) [mergedExtra addEntriesFromDictionary:self.extra];
    if (extra) [mergedExtra addEntriesFromDictionary:extra];
    
    TurboLogInfo(@"Loading ad for placement: %@", placementID);
    
    // 追踪加载开始
    [[TurboAdTracker sharedTracker] trackLoadStartWithPlacementID:placementID extra:mergedExtra];
    
    // 获取 placement 配置并开始加载
    [[TurboAdPlacementManager sharedManager] fetchPlacementSettingWithPlacementID:placementID
                                                                        extra:mergedExtra
                                                                   completion:^(TurboAdPlacementModel * _Nullable placementModel, NSError * _Nullable error) {
        if (error || !placementModel) {
            TurboLogError(@"Failed to fetch placement setting: %@", error.localizedDescription);
            [self handleLoadFailureWithPlacementID:placementID error:error];
            return;
        }
        
        // 开始 waterfall 加载
        [self.loader loadAdWithPlacementModel:placementModel
                                        extra:mergedExtra
                                   completion:^(BOOL success, TurboAdObject * _Nullable adObject, NSError * _Nullable error) {
            [self.loadingStatus setObject:@(NO) forKey:placementID];
            
            if (success && adObject) {
                // 保存广告对象
                NSMutableArray *ads = [self.adStorages objectForKey:placementID];
                if (!ads) {
                    ads = [NSMutableArray array];
                    [self.adStorages setObject:ads forKey:placementID];
                }
                [ads addObject:adObject];
                
                // 记录频控
                [[TurboAdCapsManager sharedManager] recordLoadWithPlacementID:placementID];
                
                // 追踪加载成功
                [[TurboAdTracker sharedTracker] trackLoadSuccessWithPlacementID:placementID adObject:adObject];
                
                TurboLogInfo(@"Ad loaded successfully for placement: %@", placementID);
                
                [TurboAdUtils runOnMainThread:^{
                    id<TurboAdLoadingDelegate> delegate = [self.loadingDelegates objectForKey:placementID];
                    if ([delegate respondsToSelector:@selector(didFinishLoadingAdWithPlacementID:)]) {
                        [delegate didFinishLoadingAdWithPlacementID:placementID];
                    }
                }];
            } else {
                [self handleLoadFailureWithPlacementID:placementID error:error];
            }
        }];
    }];
}

- (BOOL)isAdReadyWithPlacementID:(NSString *)placementID {
    NSArray *ads = [self.adStorages objectForKey:placementID];
    if (!ads || ads.count == 0) return NO;
    
    // 检查第一个未过期的广告
    for (TurboAdObject *ad in ads) {
        if (!ad.isShown && ![ad isExpired]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)placementStatusWithPlacementID:(NSString *)placementID {
    NSNumber *isLoading = [self.loadingStatus objectForKey:placementID];
    if (isLoading && isLoading.boolValue) {
        return 1; // 加载中
    }
    
    if ([self isAdReadyWithPlacementID:placementID]) {
        return 2; // 就绪
    }
    
    return 3; // 无广告
}

- (void)clearCacheWithPlacementID:(NSString *)placementID {
    [self.adStorages removeObjectForKey:placementID];
    TurboLogDebug(@"Cache cleared for placement: %@", placementID);
}

- (void)clearAllCache {
    [self.adStorages removeAllObjects];
    TurboLogInfo(@"All ad cache cleared");
}

/// 获取最佳广告对象（按 ecpm 排序，取最高且未过期的）
- (TurboAdObject *)offerWithPlacementID:(NSString *)placementID error:(NSError **)error {
    NSArray *ads = [self.adStorages objectForKey:placementID];
    if (!ads || ads.count == 0) {
        if (error) {
            *error = [NSError errorWithDomain:kTurboAdErrorDomain
                                         code:TurboAdErrorCodeNoAd
                                     userInfo:@{NSLocalizedDescriptionKey: @"No ad available"}];
        }
        return nil;
    }
    
    // 按 ecpm 降序排序，过滤已展示和已过期的
    NSArray *sortedAds = [ads sortedArrayUsingComparator:^NSComparisonResult(TurboAdObject *a, TurboAdObject *b) {
        return b.ecpm > a.ecpm ? NSOrderedDescending : (b.ecpm < a.ecpm ? NSOrderedAscending : NSOrderedSame);
    }];
    
    for (TurboAdObject *ad in sortedAds) {
        if (!ad.isShown && ![ad isExpired]) {
            return ad;
        }
    }
    
    if (error) {
        *error = [NSError errorWithDomain:kTurboAdErrorDomain
                                     code:TurboAdErrorCodeAdNotReady
                                 userInfo:@{NSLocalizedDescriptionKey: @"No ready ad available"}];
    }
    return nil;
}

/// 标记广告已展示
- (void)markAdAsShown:(TurboAdObject *)ad {
    if (!ad) return;
    ad.isShown = YES;
    
    // 记录展示频控
    [[TurboAdCapsManager sharedManager] recordShowWithPlacementID:ad.placementID];
    
    // 追踪展示
    [[TurboAdTracker sharedTracker] trackShowWithPlacementID:ad.placementID adObject:ad];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurboAdNotificationAdDidShow
                                                        object:nil
                                                      userInfo:@{@"placementID": ad.placementID ?: @""}];
}

#pragma mark - Private

- (void)handleLoadFailureWithPlacementID:(NSString *)placementID error:(NSError *)error {
    [self.loadingStatus setObject:@(NO) forKey:placementID];
    
    // 追踪加载失败
    [[TurboAdTracker sharedTracker] trackLoadFailureWithPlacementID:placementID error:error];
    
    TurboLogError(@"Ad load failed for placement: %@, error: %@", placementID, error.localizedDescription);
    
    [TurboAdUtils runOnMainThread:^{
        id<TurboAdLoadingDelegate> delegate = [self.loadingDelegates objectForKey:placementID];
        if ([delegate respondsToSelector:@selector(didFailToLoadAdWithPlacementID:error:)]) {
            [delegate didFailToLoadAdWithPlacementID:placementID error:error];
        }
    }];
}

@end
