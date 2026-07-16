#import "TurboSplashAdManager.h"
#import "TurboAdManager.h"
#import "TurboAdLoader.h"
#import "TurboTracker.h"

@interface TurboSplashAdManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *adCache;
@end

@implementation TurboSplashAdManager

+ (instancetype)sharedManager {
    static TurboSplashAdManager *sharedManager = nil;
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

- (void)loadSplashAdWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboSplashDelegate>)delegate {
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

- (void)showSplashAdWithPlacementID:(NSString *)placementID window:(UIWindow *)window extra:(NSDictionary *)extra delegate:(id<TurboSplashDelegate>)delegate {
    if (![self isReadyForPlacementID:placementID]) {
        NSLog(@"Splash Ad is not ready for placement ID: %@", placementID);
        return;
    }

    // Consume ad from cache
    NSMutableArray *cacheArray = self.adCache[placementID];
    NSDictionary *adData = [cacheArray firstObject];
    [cacheArray removeObjectAtIndex:0];
    NSLog(@"Showing Splash Ad for placement ID: %@ with data: %@", placementID, adData);

    [[TurboTracker sharedTracker] trackEvent:TurboTrackerEventImpression placementID:placementID adData:adData];

    if ([delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) {
        [delegate splashDidShowForPlacementID:placementID extra:extra];
    }

    // Simulate auto-close after 3 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[TurboTracker sharedTracker] trackEvent:TurboTrackerEventClose placementID:placementID adData:adData];
        if ([delegate respondsToSelector:@selector(splashDidCloseForPlacementID:extra:)]) {
            [delegate splashDidCloseForPlacementID:placementID extra:extra];
        }
    });
}

@end
