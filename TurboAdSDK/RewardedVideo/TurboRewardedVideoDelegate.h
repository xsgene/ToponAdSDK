#import <Foundation/Foundation.h>
#import "TurboAdLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TurboRewardedVideoDelegate <TurboAdLoadingDelegate>

- (void)rewardedVideoDidShowForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)rewardedVideoDidClickForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)rewardedVideoDidCloseForPlacementID:(NSString *)placementID rewarded:(BOOL)rewarded extra:(nullable NSDictionary *)extra;
- (void)rewardedVideoDidRewardSuccessForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;

@end

NS_ASSUME_NONNULL_END
