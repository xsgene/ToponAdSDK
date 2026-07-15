//
//  TurboAdInterstitialDelegate.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 插屏广告回调协议
@protocol TurboAdInterstitialDelegate <NSObject>
@optional

/// 插屏广告已展示
- (void)interstitialDidShowForPlacementID:(NSString *)placementID;

/// 插屏广告展示失败
- (void)interstitialDidFailToShowForPlacementID:(NSString *)placementID error:(NSError *)error;

/// 插屏广告开始播放视频
- (void)interstitialDidStartPlayingVideoForPlacementID:(NSString *)placementID;

/// 插屏广告结束播放视频
- (void)interstitialDidEndPlayingVideoForPlacementID:(NSString *)placementID;

/// 插屏广告视频播放失败
- (void)interstitialDidFailToPlayVideoForPlacementID:(NSString *)placementID error:(NSError *)error;

/// 插屏广告关闭
- (void)interstitialDidCloseForPlacementID:(NSString *)placementID;

/// 插屏广告被点击
- (void)interstitialDidClickForPlacementID:(NSString *)placementID;

/// 插屏广告深度链接
- (void)interstitialDidDeepLinkForPlacementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
