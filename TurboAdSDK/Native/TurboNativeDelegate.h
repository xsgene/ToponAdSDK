#import <Foundation/Foundation.h>
#import "TurboAdLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class TurboNativeAdView;

@protocol TurboNativeDelegate <TurboAdLoadingDelegate>

- (void)nativeAdDidShowForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)nativeAdDidClickForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)nativeAdDidCloseForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;

@end

NS_ASSUME_NONNULL_END
