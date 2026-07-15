//
//  TurboAdRewardedVideoAd.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdRewardedVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 激励视频广告对象
@interface TurboAdRewardedVideoAd : NSObject

@property (nonatomic, copy, readonly) NSString *placementID;
@property (nonatomic, weak, nullable) id<TurboAdRewardedVideoDelegate> delegate;

/// 广告是否就绪
- (BOOL)isReady;

/// 加载广告
- (void)loadAd;

/// 展示广告
- (BOOL)showFromViewController:(UIViewController *)viewController;

/// 展示广告（带场景）
- (BOOL)showFromViewController:(UIViewController *)viewController scene:(nullable NSString *)scene;

@end

NS_ASSUME_NONNULL_END
