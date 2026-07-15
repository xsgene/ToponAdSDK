//
//  TurboAdInterstitialAd.m
//  TurboAdSDK
//

#import "TurboAdInterstitialAd.h"
#import "TurboAdManager.h"
#import "TurboAdInterstitialManager.h"
#import "TurboAdObject.h"
#import "TurboAdConstants.h"
#import "TurboAdLogger.h"
#import "TurboAdUtils.h"
#import "TurboAdTracker.h"
#import "TurboAdCapsManager.h"

@interface TurboAdInterstitialAd () <TurboAdLoadingDelegate>
@property (nonatomic, copy, readwrite) NSString *placementID;
@property (nonatomic, strong, nullable) TurboAdObject *currentAd;
@end

@implementation TurboAdInterstitialAd

- (instancetype)initWithPlacementID:(NSString *)placementID {
    self = [super init];
    if (self) {
        _placementID = [placementID copy];
    }
    return self;
}

- (BOOL)isReady {
    return [[TurboAdInterstitialManager sharedManager] isAdReadyWithPlacementID:self.placementID];
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
        TurboLogError(@"Interstitial not ready for placement: %@", self.placementID);
        NSError *error = [NSError errorWithDomain:kTurboAdErrorDomain
                                             code:TurboAdErrorCodeAdNotReady
                                         userInfo:@{NSLocalizedDescriptionKey: @"Interstitial ad is not ready"}];
        [TurboAdUtils runOnMainThread:^{
            if ([self.delegate respondsToSelector:@selector(interstitialDidFailToShowForPlacementID:error:)]) {
                [self.delegate interstitialDidFailToShowForPlacementID:self.placementID error:error];
            }
        }];
        return NO;
    }
    
    if (![[TurboAdCapsManager sharedManager] canShowWithPlacementID:self.placementID]) {
        TurboLogWarning(@"Interstitial show blocked by frequency cap: %@", self.placementID);
        return NO;
    }
    
    NSError *error = nil;
    self.currentAd = [[TurboAdManager sharedManager] offerWithPlacementID:self.placementID error:&error];
    if (!self.currentAd) {
        [TurboAdUtils runOnMainThread:^{
            if ([self.delegate respondsToSelector:@selector(interstitialDidFailToShowForPlacementID:error:)]) {
                [self.delegate interstitialDidFailToShowForPlacementID:self.placementID error:error];
            }
        }];
        return NO;
    }
    
    [[TurboAdManager sharedManager] markAdAsShown:self.currentAd];
    
    TurboLogInfo(@"Showing interstitial for placement: %@", self.placementID);
    
    [TurboAdUtils runOnMainThread:^{
        if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:)]) {
            [self.delegate interstitialDidShowForPlacementID:self.placementID];
        }
    }];
    
    return YES;
}

#pragma mark - TurboAdLoadingDelegate

- (void)didFinishLoadingAdWithPlacementID:(NSString *)placementID {
    TurboLogDebug(@"Interstitial loaded: %@", placementID);
}

- (void)didFailToLoadAdWithPlacementID:(NSString *)placementID error:(NSError *)error {
    TurboLogDebug(@"Interstitial load failed: %@, error: %@", placementID, error.localizedDescription);
}

@end
