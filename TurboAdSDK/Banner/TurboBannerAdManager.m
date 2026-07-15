#import "TurboBannerAdManager.h"
#import "TurboAdManager.h"

@interface TurboBannerAdManager ()
@property (nonatomic, strong) NSMutableSet<NSString *> *readyPlacementIDs;
@end

@implementation TurboBannerAdManager

+ (instancetype)sharedManager {
    static TurboBannerAdManager *sharedManager = nil;
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

- (void)loadBannerAdWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboBannerDelegate>)delegate {
    [[TurboAdManager sharedManager] loadADWithPlacementID:placementID extra:extra delegate:delegate];

    // Simulate caching the ad after loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.readyPlacementIDs addObject:placementID];
    });
}

- (BOOL)isReadyForPlacementID:(NSString *)placementID {
    return [self.readyPlacementIDs containsObject:placementID];
}

- (TurboBannerView *)getBannerViewWithPlacementID:(NSString *)placementID {
    if (![self isReadyForPlacementID:placementID]) {
        NSLog(@"Banner Ad is not ready for placement ID: %@", placementID);
        return nil;
    }

    [self.readyPlacementIDs removeObject:placementID]; // Consume

    TurboBannerView *bannerView = [[TurboBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [bannerView loadBannerAd];

    return bannerView;
}

@end
