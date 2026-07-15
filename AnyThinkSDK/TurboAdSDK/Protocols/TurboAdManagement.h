//
//  TurboAdManagement.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TurboAdObject;

/// 广告存储管理协议 - 各广告类型 Manager 需实现
@protocol TurboAdManagement <NSObject>

@required
/// 添加广告对象
- (void)addAdWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject;

/// 获取指定广告位的广告对象列表
- (NSArray<TurboAdObject *> *)adsWithPlacementID:(NSString *)placementID;

/// 移除指定广告位的广告
- (void)removeAdWithPlacementID:(NSString *)placementID;

/// 清除所有缓存
- (void)clearCache;

/// 检查广告是否就绪
- (BOOL)isAdReadyWithPlacementID:(NSString *)placementID;

/// 获取广告状态
- (NSInteger)placementStatusWithPlacementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
