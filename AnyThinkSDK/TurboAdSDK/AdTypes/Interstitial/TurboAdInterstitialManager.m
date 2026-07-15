//
//  TurboAdInterstitialManager.m
//  TurboAdSDK
//

#import "TurboAdInterstitialManager.h"
#import "TurboAdObject.h"
#import "TurboAdThreadSafe.h"
#import "TurboAdLogger.h"

@interface TurboAdInterstitialManager ()
@property (nonatomic, strong) TurboAdThreadSafeDictionary *adCache;
@end

@implementation TurboAdInterstitialManager

+ (instancetype)sharedManager {
    static TurboAdInterstitialManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _adCache = [[TurboAdThreadSafeDictionary alloc] initWithQueueLabel:@"com.turboadsdk.interstitial.cache"];
    }
    return self;
}

- (void)addAdWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject {
    NSMutableArray *ads = [self.adCache objectForKey:placementID];
    if (!ads) {
        ads = [NSMutableArray array];
        [self.adCache setObject:ads forKey:placementID];
    }
    [ads addObject:adObject];
    TurboLogDebug(@"Interstitial ad added for: %@, total: %lu", placementID, (unsigned long)ads.count);
}

- (NSArray<TurboAdObject *> *)adsWithPlacementID:(NSString *)placementID {
    NSArray *ads = [self.adCache objectForKey:placementID];
    return ads ?: @[];
}

- (void)removeAdWithPlacementID:(NSString *)placementID {
    [self.adCache removeObjectForKey:placementID];
}

- (void)clearCache {
    [self.adCache removeAllObjects];
    TurboLogInfo(@"Interstitial cache cleared");
}

- (BOOL)isAdReadyWithPlacementID:(NSString *)placementID {
    NSArray *ads = [self.adCache objectForKey:placementID];
    if (!ads || ads.count == 0) return NO;
    for (TurboAdObject *ad in ads) {
        if (!ad.isShown && ![ad isExpired]) return YES;
    }
    return NO;
}

- (NSInteger)placementStatusWithPlacementID:(NSString *)placementID {
    return [self isAdReadyWithPlacementID:placementID] ? 2 : 3;
}

@end
