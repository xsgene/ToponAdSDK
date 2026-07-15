#import "TurboInterstitialAdManager.h"
#import "TurboAdManager.h"

@interface TurboInterstitialAdManager ()
@property (nonatomic, strong) NSMutableSet<NSString *> *readyPlacementIDs;
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
        _readyPlacementIDs = [NSMutableSet set];
    }
    return self;
}

- (void)loadInterstitialAdWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboInterstitialDelegate>)delegate {
    [[TurboAdManager sharedManager] loadADWithPlacementID:placementID extra:extra delegate:delegate];

    // Simulate caching the ad after loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.readyPlacementIDs addObject:placementID];
    });
}

- (BOOL)isReadyForPlacementID:(NSString *)placementID {
    return [self.readyPlacementIDs containsObject:placementID];
}

- (void)showInterstitialAdWithPlacementID:(NSString *)placementID inViewController:(UIViewController *)viewController delegate:(id<TurboInterstitialDelegate>)delegate {
    if (![self isReadyForPlacementID:placementID]) {
        NSLog(@"Interstitial Ad is not ready for placement ID: %@", placementID);
        return;
    }

    NSLog(@"Showing Interstitial Ad for placement ID: %@", placementID);
    [self.readyPlacementIDs removeObject:placementID]; // Consume the ad

    if ([delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) {
        [delegate interstitialDidShowForPlacementID:placementID extra:nil];
    }
}

@end
