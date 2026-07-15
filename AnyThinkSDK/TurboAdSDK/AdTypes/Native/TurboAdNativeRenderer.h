//
//  TurboAdNativeRenderer.h
//  TurboAdSDK
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TurboAdNativeAd;

/// 原生广告渲染器协议
@protocol TurboAdNativeRenderer <NSObject>

@required
/// 创建媒体视图
- (UIView *)createMediaView;

/// 渲染广告
- (void)renderAd:(TurboAdNativeAd *)nativeAd;

@optional
/// 是否包含视频内容
- (BOOL)isVideoContents;

/// 渲染器版本
+ (NSString *)rendererVersion;

@end

NS_ASSUME_NONNULL_END
