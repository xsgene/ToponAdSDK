#import <Foundation/Foundation.h>
#import "TurboNativeDelegate.h"
#import "TurboNativeAdView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TurboNativeAdManager : NSObject

+ (instancetype)sharedManager;

- (void)loadNativeAdWithPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra delegate:(id<TurboNativeDelegate>)delegate;
- (BOOL)isReadyForPlacementID:(NSString *)placementID;
- (nullable TurboNativeAdView *)getNativeAdViewWithPlacementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
