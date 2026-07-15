//
//  TurboAdNativeDelegate.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 原生广告回调协议
@protocol TurboAdNativeDelegate <NSObject>
@optional

/// 原生广告加载成功
- (void)nativeAdDidLoadForPlacementID:(NSString *)placementID;

/// 原生广告加载失败
- (void)nativeAdDidFailToLoadForPlacementID:(NSString *)placementID error:(NSError *)error;

/// 原生广告已展示
- (void)nativeAdDidShowForPlacementID:(NSString *)placementID;

/// 原生广告被点击
- (void)nativeAdDidClickForPlacementID:(NSString *)placementID;

/// 原生广告视频开始播放
- (void)nativeAdDidStartPlayingVideoForPlacementID:(NSString *)placementID;

/// 原生广告视频结束播放
- (void)nativeAdDidEndPlayingVideoForPlacementID:(NSString *)placementID;

/// 原生广告进入全屏视频
- (void)nativeAdDidEnterFullScreenVideoForPlacementID:(NSString *)placementID;

/// 原生广告退出全屏视频
- (void)nativeAdDidExitFullScreenVideoForPlacementID:(NSString *)placementID;

/// 原生广告关闭按钮被点击
- (void)nativeAdDidTapCloseButtonForPlacementID:(NSString *)placementID;

/// 原生广告深度链接
- (void)nativeAdDidDeepLinkForPlacementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
