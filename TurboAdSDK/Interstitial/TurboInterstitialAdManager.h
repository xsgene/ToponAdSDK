#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TurboInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TurboInterstitialAdManager : NSObject

+ (instancetype)sharedManager;

- (void)loadInterstitialAdWithPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra delegate:(id<TurboInterstitialDelegate>)delegate;
- (BOOL)isReadyForPlacementID:(NSString *)placementID;
- (void)showInterstitialAdWithPlacementID:(NSString *)placementID inViewController:(UIViewController *)viewController delegate:(id<TurboInterstitialDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
