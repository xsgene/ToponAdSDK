//
//  TurboAdTracker.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TurboAdObject;

/// 事件追踪管理器
@interface TurboAdTracker : NSObject

+ (instancetype)sharedTracker;

/// 追踪加载开始
- (void)trackLoadStartWithPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra;

/// 追踪加载成功
- (void)trackLoadSuccessWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject;

/// 追踪加载失败
- (void)trackLoadFailureWithPlacementID:(NSString *)placementID error:(nullable NSError *)error;

/// 追踪展示
- (void)trackShowWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject;

/// 追踪点击
- (void)trackClickWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject;

/// 追踪关闭
- (void)trackCloseWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject;

/// 追踪视频播放开始
- (void)trackVideoStartWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject;

/// 追踪视频播放结束
- (void)trackVideoEndWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject;

/// 追踪自定义事件
- (void)trackEvent:(NSString *)event placementID:(nullable NSString *)placementID parameters:(nullable NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
