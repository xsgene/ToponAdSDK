//
//  TurboAdRewardedVideoAd.m
//  TurboAdSDK
//

#import "TurboAdRewardedVideoAd.h"
#import "TurboAdManager.h"
#import "TurboAdRewardedVideoManager.h"
#import "TurboAdObject.h"
#import "TurboAdConstants.h"
#import "TurboAdLogger.h"
#import "TurboAdUtils.h"
#import "TurboAdTracker.h"
#import "TurboAdCapsManager.h"

@interface TurboAdRewardedVideoAd () <TurboAdLoadingDelegate>
@property (nonatomic, copy, readwrite) NSString *placementID;
@property (nonatomic, strong, nullable) TurboAdObject *currentAd;
@end

@implementation TurboAdRewardedVideoAd

- (instancetype)initWithPlacementID:(NSString *)placementID {
    self = [super init];
    if (self) {
        _placementID = [placementID copy];
    }
    return self;
}

- (BOOL)isReady {
    return [[TurboAdRewardedVideoManager sharedManager] isAdReadyWithPlacementID:self.placementID];
}

- (void)loadAd {
    [[TurboAdManager sharedManager] loadADWithPlacementID:self.placementID
                                                   extra:nil
                                                delegate:self];
}

- (BOOL)showFromViewController:(UIViewController *)viewController {
    return [self showFromViewController:viewController scene:nil];
}

- (BOOL)showFromViewController:(UIViewController *)viewController scene:(NSString *)scene {
    if (![self isReady]) {
        TurboLogError(@"Rewarded video not ready for placement: %@", self.placementID);
        NSError *error = [NSError errorWithDomain:kTurboAdErrorDomain
                                             code:TurboAdErrorCodeAdNotReady
                                         userInfo:@{NSLocalizedDescriptionKey: @"Rewarded video ad is not ready"}];
        [TurboAdUtils runOnMainThread:^{
            if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:)]) {
                [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.placementID error:error];
            }
        }];
        return NO;
    }
    
    // 检查展示频控
    if (![[TurboAdCapsManager sharedManager] canShowWithPlacementID:self.placementID]) {
        TurboLogWarning(@"Rewarded video show blocked by frequency cap: %@", self.placementID);
        return NO;
    }
    
    // 获取广告对象
    NSError *error = nil;
    self.currentAd = [[TurboAdManager sharedManager] offerWithPlacementID:self.placementID error:&error];
    if (!self.currentAd) {
        [TurboAdUtils runOnMainThread:^{
            if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:)]) {
                [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.placementID error:error];
            }
        }];
        return NO;
    }
    
    // 标记为已展示
    [[TurboAdManager sharedManager] markAdAsShown:self.currentAd];
    
    TurboLogInfo(@"Showing rewarded video for placement: %@", self.placementID);
    
    // 通知展示
    [TurboAdUtils runOnMainThread:^{
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:)]) {
            [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.placementID];
        }
    }];
    
    return YES;
}

#pragma mark - TurboAdLoadingDelegate

- (void)didFinishLoadingAdWithPlacementID:(NSString *)placementID {
    TurboLogDebug(@"Rewarded video loaded: %@", placementID);
}

- (void)didFailToLoadAdWithPlacementID:(NSString *)placementID error:(NSError *)error {
    TurboLogDebug(@"Rewarded video load failed: %@, error: %@", placementID, error.localizedDescription);
}

@end
