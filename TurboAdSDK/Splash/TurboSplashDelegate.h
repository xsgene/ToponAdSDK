#import <Foundation/Foundation.h>
#import "TurboAdLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TurboSplashDelegate <TurboAdLoadingDelegate>

- (void)splashDidShowForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)splashDidClickForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;
- (void)splashDidCloseForPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;

@end

NS_ASSUME_NONNULL_END
