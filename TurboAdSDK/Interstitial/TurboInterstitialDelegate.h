#import <Foundation/Foundation.h>
#import "TurboAdLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TurboInterstitialDelegate <TurboAdLoadingDelegate>

- (void)interstitialDidShowForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)interstitialDidClickForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)interstitialDidCloseForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;

@end

NS_ASSUME_NONNULL_END
