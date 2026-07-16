#import <Foundation/Foundation.h>
#import "TurboBannerDelegate.h"
#import "TurboBannerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TurboBannerAdManager : NSObject

+ (instancetype)sharedManager;

- (void)loadBannerAdWithPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra delegate:(id<TurboBannerDelegate>)delegate;
- (BOOL)isReadyForPlacementID:(NSString *)placementID;
- (nullable TurboBannerView *)getBannerViewWithPlacementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
