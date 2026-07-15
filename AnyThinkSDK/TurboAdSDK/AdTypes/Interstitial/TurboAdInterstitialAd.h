//
//  TurboAdInterstitialAd.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TurboAdInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 插屏广告对象
@interface TurboAdInterstitialAd : NSObject

@property (nonatomic, copy, readonly) NSString *placementID;
@property (nonatomic, weak, nullable) id<TurboAdInterstitialDelegate> delegate;

- (instancetype)initWithPlacementID:(NSString *)placementID;

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
