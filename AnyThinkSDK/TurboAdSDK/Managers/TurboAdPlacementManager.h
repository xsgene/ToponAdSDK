//
//  TurboAdPlacementManager.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TurboAdPlacementModel;

/// 广告位配置管理器
@interface TurboAdPlacementManager : NSObject

+ (instancetype)sharedManager;

/// 获取广告位配置
- (void)fetchPlacementSettingWithPlacementID:(NSString *)placementID
                                       extra:(nullable NSDictionary *)extra
                                  completion:(void(^)(TurboAdPlacementModel * _Nullable model, NSError * _Nullable error))completion;

/// 从缓存获取广告位配置
- (nullable TurboAdPlacementModel *)cachedPlacementModelWithPlacementID:(NSString *)placementID;

/// 清除缓存
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
