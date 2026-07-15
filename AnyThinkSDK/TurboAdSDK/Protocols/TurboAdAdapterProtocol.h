//
//  TurboAdAdapterProtocol.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TurboAdPlacementModel;
@class TurboAdUnitModel;
@class TurboAdObject;

/// 广告适配器初始化回调
typedef void(^TurboAdAdapterInitCompletion)(BOOL success, NSError * _Nullable error);

/// 广告适配器加载回调
typedef void(^TurboAdAdapterLoadCompletion)(BOOL success, id _Nullable adObject, NSError * _Nullable error);

/// 广告适配器协议 - 所有广告网络适配器必须实现
@protocol TurboAdAdapterProtocol <NSObject>

@required
/// 适配器初始化
- (instancetype)initWithUnitModel:(TurboAdUnitModel *)unitModel;

/// 加载广告
- (void)loadAdWithPlacementModel:(TurboAdPlacementModel *)placementModel
                       completion:(TurboAdAdapterLoadCompletion)completion;

/// 检查广告是否就绪
- (BOOL)isAdReady;

@optional
/// 获取适配器版本
+ (NSString *)adapterVersion;

/// 获取网络 SDK 版本
+ (NSString *)networkSDKVersion;

/// 竞价请求
- (void)bidRequestWithPlacementModel:(TurboAdPlacementModel *)placementModel
                          completion:(void(^)(BOOL success, double price, NSError * _Nullable error))completion;

@end

/// 激励视频适配器协议
@protocol TurboAdRewardedVideoAdapterProtocol <TurboAdAdapterProtocol>
@required
- (void)showRewardedVideoInViewController:(UIViewController *)viewController
                                 delegate:(id)delegate;
@end

/// 插屏适配器协议
@protocol TurboAdInterstitialAdapterProtocol <TurboAdAdapterProtocol>
@required
- (void)showInterstitialInViewController:(UIViewController *)viewController
                                delegate:(id)delegate;
@end

/// 横幅适配器协议
@protocol TurboAdBannerAdapterProtocol <TurboAdAdapterProtocol>
@required
- (UIView *)bannerViewWithSize:(CGSize)size;
- (void)startAutoRefreshWithInterval:(NSTimeInterval)interval;
- (void)stopAutoRefresh;
@end

/// 开屏适配器协议
@protocol TurboAdSplashAdapterProtocol <TurboAdAdapterProtocol>
@required
- (void)showSplashInWindow:(UIWindow *)window
                  delegate:(id)delegate;
@end

/// 原生适配器协议
@protocol TurboAdNativeAdapterProtocol <TurboAdAdapterProtocol>
@required
- (void)renderNativeAdInView:(UIView *)containerView
               configuration:(NSDictionary *)configuration;
@end

NS_ASSUME_NONNULL_END
