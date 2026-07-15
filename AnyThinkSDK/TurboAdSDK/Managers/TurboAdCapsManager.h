//
//  TurboAdCapsManager.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 频控管理器
@interface TurboAdCapsManager : NSObject

+ (instancetype)sharedManager;

/// 检查是否可以加载
- (BOOL)canLoadWithPlacementID:(NSString *)placementID;

/// 检查是否可以展示
- (BOOL)canShowWithPlacementID:(NSString *)placementID;

/// 记录加载
- (void)recordLoadWithPlacementID:(NSString *)placementID;

/// 记录展示
- (void)recordShowWithPlacementID:(NSString *)placementID;

/// 设置频控参数
- (void)setPacing:(NSTimeInterval)pacing
          capByDay:(NSInteger)capByDay
         capByHour:(NSInteger)capByHour
   forPlacementID:(NSString *)placementID;

/// 重置频控记录
- (void)resetRecordsWithPlacementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
