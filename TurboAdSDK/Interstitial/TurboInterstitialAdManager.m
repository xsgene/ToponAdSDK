#import "TurboInterstitialAdManager.h"
#import "TurboAdManager.h"

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
    // Simulate async ad load
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (placementID.length > 0) {
            NSString *mockAdData = [NSString stringWithFormat:@"InterstitialAdData_%f", [[NSDate date] timeIntervalSince1970]];
            NSMutableArray *cacheArray = self.adCache[placementID];
            if (!cacheArray) {
                cacheArray = [NSMutableArray array];
                self.adCache[placementID] = cacheArray;
            }
            [cacheArray addObject:mockAdData];

            if ([delegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) {
                [delegate didFinishLoadingADWithPlacementID:placementID];
            }
        } else {
            if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
                NSError *error = [NSError errorWithDomain:@"TurboAdSDK" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid placement ID"}];
                [delegate didFailToLoadADWithPlacementID:placementID error:error];
            }
        }
    });
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
    NSString *adData = [cacheArray firstObject];
    [cacheArray removeObjectAtIndex:0];
    NSLog(@"Showing Interstitial Ad for placement ID: %@ with data: %@", placementID, adData);

    if ([delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) {
        [delegate interstitialDidShowForPlacementID:placementID extra:nil];
    }
}

@end
