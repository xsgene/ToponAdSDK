//
//  TurboAdBannerDelegate.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TurboAdBannerView;

/// 横幅广告回调协议
@protocol TurboAdBannerDelegate <NSObject>
@optional

/// 横幅广告加载成功
- (void)bannerViewDidLoad:(TurboAdBannerView *)bannerView;

/// 横幅广告加载失败
- (void)bannerView:(TurboAdBannerView *)bannerView didFailWithError:(NSError *)error;

/// 横幅广告已展示
- (void)bannerViewDidShow:(TurboAdBannerView *)bannerView;

/// 横幅广告被点击
- (void)bannerViewDidClick:(TurboAdBannerView *)bannerView;

/// 横幅广告关闭
- (void)bannerViewDidClose:(TurboAdBannerView *)bannerView;

/// 横幅广告自动刷新
- (void)bannerViewDidAutoRefresh:(TurboAdBannerView *)bannerView;

/// 横幅广告自动刷新失败
- (void)bannerView:(TurboAdBannerView *)bannerView didFailToAutoRefreshWithError:(NSError *)error;

/// 横幅广告关闭按钮被点击
- (void)bannerViewDidTapCloseButton:(TurboAdBannerView *)bannerView;

/// 横幅广告深度链接
- (void)bannerViewDidDeepLink:(TurboAdBannerView *)bannerView;

@end

NS_ASSUME_NONNULL_END
