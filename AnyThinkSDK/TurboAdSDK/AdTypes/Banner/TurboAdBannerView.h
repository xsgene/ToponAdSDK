//
//  TurboAdBannerView.h
//  TurboAdSDK
//

#import <UIKit/UIKit.h>
#import "TurboAdBannerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 横幅广告视图
@interface TurboAdBannerView : UIView

@property (nonatomic, copy, readonly) NSString *placementID;
@property (nonatomic, weak, nullable) id<TurboAdBannerDelegate> delegate;

/// 是否正在自动刷新
@property (nonatomic, assign, readonly) BOOL isAutoRefreshing;

/// 初始化
- (instancetype)initWithFrame:(CGRect)frame placementID:(NSString *)placementID;

/// 加载广告
- (void)loadAd;

/// 开始自动刷新
- (void)startAutoRefresh;

/// 停止自动刷新
- (void)stopAutoRefresh;

/// 设置自动刷新间隔（秒）
- (void)setAutoRefreshInterval:(NSTimeInterval)interval;

@end

NS_ASSUME_NONNULL_END
