#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TurboRewardedVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TurboRewardedVideoAdManager : NSObject

+ (instancetype)sharedManager;

- (void)loadRewardedVideoWithPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra delegate:(id<TurboRewardedVideoDelegate>)delegate;
- (BOOL)isReadyForPlacementID:(NSString *)placementID;
- (void)showRewardedVideoWithPlacementID:(NSString *)placementID inViewController:(UIViewController *)viewController delegate:(id<TurboRewardedVideoDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
