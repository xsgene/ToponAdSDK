#import "TurboRewardedVideoAdManager.h"
#import "TurboAdManager.h"

@interface TurboRewardedVideoAdManager ()
@property (nonatomic, strong) NSMutableSet<NSString *> *readyPlacementIDs;
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
        _readyPlacementIDs = [NSMutableSet set];
    }
    return self;
}

- (void)loadRewardedVideoWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboRewardedVideoDelegate>)delegate {
    [[TurboAdManager sharedManager] loadADWithPlacementID:placementID extra:extra delegate:delegate];

    // Simulate caching the ad after loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.readyPlacementIDs addObject:placementID];
    });
}

- (BOOL)isReadyForPlacementID:(NSString *)placementID {
    return [self.readyPlacementIDs containsObject:placementID];
}

- (void)showRewardedVideoWithPlacementID:(NSString *)placementID inViewController:(UIViewController *)viewController delegate:(id<TurboRewardedVideoDelegate>)delegate {
    if (![self isReadyForPlacementID:placementID]) {
        NSLog(@"Rewarded Video Ad is not ready for placement ID: %@", placementID);
        return;
    }

    NSLog(@"Showing Rewarded Video Ad for placement ID: %@", placementID);
    [self.readyPlacementIDs removeObject:placementID]; // Consume the ad

    if ([delegate respondsToSelector:@selector(rewardedVideoDidShowForPlacementID:extra:)]) {
        [delegate rewardedVideoDidShowForPlacementID:placementID extra:nil];
    }

    // Simulate video playing and rewarding
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacementID:extra:)]) {
            [delegate rewardedVideoDidRewardSuccessForPlacementID:placementID extra:nil];
        }
        if ([delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
            [delegate rewardedVideoDidCloseForPlacementID:placementID rewarded:YES extra:nil];
        }
    });
}

@end
