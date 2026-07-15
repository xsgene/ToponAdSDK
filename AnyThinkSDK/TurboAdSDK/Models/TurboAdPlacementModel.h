//
//  TurboAdPlacementModel.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class TurboAdUnitModel;

/// 广告位配置模型
@interface TurboAdPlacementModel : NSObject

@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, assign) TurboAdFormat format;
@property (nonatomic, assign) TurboAdShowType showType;
@property (nonatomic, copy) NSArray<TurboAdUnitModel *> *unitGroups;
@property (nonatomic, copy) NSArray<TurboAdUnitModel *> *headerBiddingUnitGroups;

/// 频控配置
@property (nonatomic, assign) NSTimeInterval pacing;          // 展示间隔（秒）
@property (nonatomic, assign) NSInteger capByDay;             // 每日展示上限
@property (nonatomic, assign) NSInteger capByHour;            // 每小时展示上限

/// 自动刷新配置（Banner）
@property (nonatomic, assign) BOOL isAutoRefresh;
@property (nonatomic, assign) NSTimeInterval autoRefreshInterval;

/// 最大并发请求数
@property (nonatomic, assign) NSInteger maxConcurrentRequestCount;

/// 请求ID
@property (nonatomic, copy) NSString *requestID;

/// 从字典初始化
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

/// 获取所有 unit groups（普通 + header bidding）
- (NSArray<TurboAdUnitModel *> *)allUnitGroups;

@end

NS_ASSUME_NONNULL_END
