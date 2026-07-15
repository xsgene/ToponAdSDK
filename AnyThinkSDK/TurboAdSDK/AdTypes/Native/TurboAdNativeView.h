//
//  TurboAdNativeView.h
//  TurboAdSDK
//

#import <UIKit/UIKit.h>
#import "TurboAdNativeDelegate.h"
#import "TurboAdNativeRendering.h"

NS_ASSUME_NONNULL_BEGIN

@class TurboAdNativeAd;

/// 原生广告配置
@interface TurboAdNativeConfiguration : NSObject
/// 自定义渲染视图类（需实现 TurboAdNativeRendering 协议）
@property (nonatomic, assign) Class renderingViewClass;
/// 广告 frame
@property (nonatomic, assign) CGRect adFrame;
/// 媒体视图 frame
@property (nonatomic, assign) CGRect mediaViewFrame;
/// 代理
@property (nonatomic, weak, nullable) id<TurboAdNativeDelegate> delegate;
@end

/// 原生广告视图
@interface TurboAdNativeView : UIView

@property (nonatomic, copy, readonly) NSString *placementID;
@property (nonatomic, weak, nullable) id<TurboAdNativeDelegate> delegate;
@property (nonatomic, strong, readonly, nullable) TurboAdNativeAd *nativeAd;

- (instancetype)initWithFrame:(CGRect)frame placementID:(NSString *)placementID;

/// 加载广告
- (void)loadAd;

/// 渲染广告（使用自定义渲染视图）
- (void)renderWithNativeAd:(TurboAdNativeAd *)nativeAd
         renderingViewClass:(Class<TurboAdNativeRendering>)renderingViewClass;

/// 注册可点击视图
- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews;

@end

NS_ASSUME_NONNULL_END
