//
//  TurboAdSplashDelegate.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 开屏广告回调协议
@protocol TurboAdSplashDelegate <NSObject>
@optional

/// 开屏广告已展示
- (void)splashDidShowForPlacementID:(NSString *)placementID;

/// 开屏广告展示失败
- (void)splashDidFailToShowForPlacementID:(NSString *)placementID error:(NSError *)error;

/// 开屏广告被点击
- (void)splashDidClickForPlacementID:(NSString *)placementID;

/// 开屏广告关闭
- (void)splashDidCloseForPlacementID:(NSString *)placementID;

/// 开屏广告深度链接
- (void)splashDidDeepLinkForPlacementID:(NSString *)placementID;

/// 开屏广告 ZoomOut 视图被点击
- (void)splashZoomOutViewDidClickForPlacementID:(NSString *)placementID;

/// 开屏广告 ZoomOut 视图被关闭
- (void)splashZoomOutViewDidCloseForPlacementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
