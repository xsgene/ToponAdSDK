#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TurboSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TurboSplashAdManager : NSObject

+ (instancetype)sharedManager;

- (void)loadSplashAdWithPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra delegate:(id<TurboSplashDelegate>)delegate;
- (BOOL)isReadyForPlacementID:(NSString *)placementID;
- (void)showSplashAdWithPlacementID:(NSString *)placementID window:(UIWindow *)window extra:(nullable NSDictionary *)extra delegate:(id<TurboSplashDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
