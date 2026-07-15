#import "TurboSplashAdManager.h"
#import "TurboAdManager.h"

@implementation TurboSplashAdManager

+ (instancetype)sharedManager {
    static TurboSplashAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)loadSplashAdWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboSplashDelegate>)delegate {
    [[TurboAdManager sharedManager] loadADWithPlacementID:placementID extra:extra delegate:delegate];
}

- (void)showSplashAdWithPlacementID:(NSString *)placementID window:(UIWindow *)window extra:(NSDictionary *)extra delegate:(id<TurboSplashDelegate>)delegate {
    NSLog(@"Showing Splash Ad for placement ID: %@", placementID);

    if ([delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) {
        [delegate splashDidShowForPlacementID:placementID extra:extra];
    }

    // Simulate auto-close after 3 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([delegate respondsToSelector:@selector(splashDidCloseForPlacementID:extra:)]) {
            [delegate splashDidCloseForPlacementID:placementID extra:extra];
        }
    });
}

@end
