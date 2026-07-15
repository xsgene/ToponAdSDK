//
//  TurboAdSplashAd.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TurboAdSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 开屏广告对象 - 加载与展示分离
@interface TurboAdSplashAd : NSObject

@property (nonatomic, copy, readonly) NSString *placementID;
@property (nonatomic, weak, nullable) id<TurboAdSplashDelegate> delegate;

/// 广告是否就绪
@property (nonatomic, assign, readonly) BOOL isReady;

/// ZoomOut 视图（可选，展示在首页右下角的小图）
@property (nonatomic, strong, readonly, nullable) UIView *zoomOutView;

- (instancetype)initWithPlacementID:(NSString *)placementID;

/// 加载广告
- (void)loadAd;

/// 加载广告（带容器视图，用于 ZoomOut）
- (void)loadAdWithContainerView:(nullable UIView *)containerView;

/// 展示广告到 window
- (BOOL)showInWindow:(UIWindow *)window;

/// 展示广告到 window（带底部视图）
- (BOOL)showInWindow:(UIWindow *)window bottomView:(nullable UIView *)bottomView;

@end

NS_ASSUME_NONNULL_END
