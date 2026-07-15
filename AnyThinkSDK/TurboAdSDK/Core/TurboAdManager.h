//
//  TurboAdManager.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 广告管理单例 - 核心调度入口
@interface TurboAdManager : NSObject

/// 全局 extra 参数，会附加到所有广告请求中
@property (nonatomic, copy, nullable) NSDictionary *extra;

+ (instancetype)sharedManager;

/// 加载广告
- (void)loadADWithPlacementID:(NSString *)placementID
                        extra:(nullable NSDictionary *)extra
                     delegate:(id<TurboAdLoadingDelegate>)delegate;

/// 检查广告是否就绪
- (BOOL)isAdReadyWithPlacementID:(NSString *)placementID;

/// 获取广告位状态
/// 0: 未知, 1: 加载中, 2: 就绪, 3: 无广告
- (NSInteger)placementStatusWithPlacementID:(NSString *)placementID;

/// 清除指定广告位的缓存
- (void)clearCacheWithPlacementID:(NSString *)placementID;

/// 清除所有缓存
- (void)clearAllCache;

@end

NS_ASSUME_NONNULL_END
