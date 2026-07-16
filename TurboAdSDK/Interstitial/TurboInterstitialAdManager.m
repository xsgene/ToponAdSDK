#import "TurboInterstitialAdManager.h"
#import "TurboAdManager.h"
#import "TurboAdLoader.h"
#import "TurboTracker.h"

@interface TurboInterstitialAdManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *adCache;
@end

@implementation TurboInterstitialAdManager

+ (instancetype)sharedManager {
    static TurboInterstitialAdManager *sharedManager = nil;
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

- (void)loadInterstitialAdWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboInterstitialDelegate>)delegate {
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

- (void)showInterstitialAdWithPlacementID:(NSString *)placementID inViewController:(UIViewController *)viewController delegate:(id<TurboInterstitialDelegate>)delegate {
    if (![self isReadyForPlacementID:placementID]) {
        NSLog(@"Interstitial Ad is not ready for placement ID: %@", placementID);
        return;
    }

    // Consume from cache
    NSMutableArray *cacheArray = self.adCache[placementID];
    NSDictionary *adData = [cacheArray firstObject];
    [cacheArray removeObjectAtIndex:0];
    NSLog(@"Showing Interstitial Ad for placement ID: %@ with data: %@", placementID, adData);

    [[TurboTracker sharedTracker] trackEvent:TurboTrackerEventImpression placementID:placementID adData:adData];

    if ([delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) {
        [delegate interstitialDidShowForPlacementID:placementID extra:nil];
    }
}

@end
