#import <Foundation/Foundation.h>
#import "TurboAdLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TurboBannerDelegate <TurboAdLoadingDelegate>

- (void)bannerDidShowForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)bannerDidClickForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)bannerDidCloseForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;

@end

NS_ASSUME_NONNULL_END
