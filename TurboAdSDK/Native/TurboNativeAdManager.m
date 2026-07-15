#import "TurboNativeAdManager.h"
#import "TurboAdManager.h"

@interface TurboNativeAdManager ()
@property (nonatomic, strong) NSMutableSet<NSString *> *readyPlacementIDs;
@end

@implementation TurboNativeAdManager

+ (instancetype)sharedManager {
    static TurboNativeAdManager *sharedManager = nil;
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

- (void)loadNativeAdWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboNativeDelegate>)delegate {
    [[TurboAdManager sharedManager] loadADWithPlacementID:placementID extra:extra delegate:delegate];

    // Simulate caching the ad after loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.readyPlacementIDs addObject:placementID];
    });
}

- (BOOL)isReadyForPlacementID:(NSString *)placementID {
    return [self.readyPlacementIDs containsObject:placementID];
}

- (TurboNativeAdView *)getNativeAdViewWithPlacementID:(NSString *)placementID {
    if (![self isReadyForPlacementID:placementID]) {
        NSLog(@"Native Ad is not ready for placement ID: %@", placementID);
        return nil;
    }

    [self.readyPlacementIDs removeObject:placementID]; // Consume

    TurboNativeAdView *adView = [[TurboNativeAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    adView.titleLabel.text = @"Native Ad Title";
    adView.bodyLabel.text = @"Native Ad Body";
    [adView.callToActionButton setTitle:@"Click Me" forState:UIControlStateNormal];

    return adView;
}

@end
