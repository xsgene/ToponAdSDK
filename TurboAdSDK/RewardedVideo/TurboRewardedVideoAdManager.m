#import "TurboRewardedVideoAdManager.h"
#import "TurboAdManager.h"
#import "TurboAdLoader.h"
#import "TurboTracker.h"

@interface TurboRewardedVideoAdManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *adCache;
@end

@implementation TurboRewardedVideoAdManager

+ (instancetype)sharedManager {
    static TurboRewardedVideoAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _adCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadRewardedVideoWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboRewardedVideoDelegate>)delegate {
    [[TurboAdLoader sharedLoader] requestAdWithPlacementID:placementID extra:extra completion:^(NSDictionary * _Nullable offerDict, NSError * _Nullable error) {
        if (error) {
            if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
                [delegate didFailToLoadADWithPlacementID:placementID error:error];
            }
        } else if (offerDict) {
            NSMutableArray *cacheArray = self.adCache[placementID];
            if (!cacheArray) {
                cacheArray = [NSMutableArray array];
                self.adCache[placementID] = cacheArray;
            }
            [cacheArray addObject:offerDict];

            if ([delegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) {
                [delegate didFinishLoadingADWithPlacementID:placementID];
            }
        }
    }];
}

- (BOOL)isReadyForPlacementID:(NSString *)placementID {
    NSMutableArray *cacheArray = self.adCache[placementID];
    return cacheArray && cacheArray.count > 0;
}

- (void)showRewardedVideoWithPlacementID:(NSString *)placementID inViewController:(UIViewController *)viewController delegate:(id<TurboRewardedVideoDelegate>)delegate {
    if (![self isReadyForPlacementID:placementID]) {
        NSLog(@"Rewarded Video Ad is not ready for placement ID: %@", placementID);
        return;
    }

    // Consume from cache
    NSMutableArray *cacheArray = self.adCache[placementID];
    NSDictionary *adData = [cacheArray firstObject];
    [cacheArray removeObjectAtIndex:0];
    NSLog(@"Showing Rewarded Video Ad for placement ID: %@ with data: %@", placementID, adData);

    [[TurboTracker sharedTracker] trackEvent:TurboTrackerEventImpression placementID:placementID adData:adData];
    [[TurboTracker sharedTracker] trackEvent:TurboTrackerEventVideoStart placementID:placementID adData:adData];

    if ([delegate respondsToSelector:@selector(rewardedVideoDidShowForPlacementID:extra:)]) {
        [delegate rewardedVideoDidShowForPlacementID:placementID extra:nil];
    }

    // Simulate video playing and rewarding
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[TurboTracker sharedTracker] trackEvent:TurboTrackerEventVideoEnd placementID:placementID adData:adData];
        [[TurboTracker sharedTracker] trackEvent:TurboTrackerEventRewarded placementID:placementID adData:adData];
        if ([delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacementID:extra:)]) {
            [delegate rewardedVideoDidRewardSuccessForPlacementID:placementID extra:nil];
        }
        [[TurboTracker sharedTracker] trackEvent:TurboTrackerEventClose placementID:placementID adData:adData];
        if ([delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [delegate rewardedVideoDidCloseForPlacementID:placementID rewarded:YES extra:nil];
        }
    });
}

@end
