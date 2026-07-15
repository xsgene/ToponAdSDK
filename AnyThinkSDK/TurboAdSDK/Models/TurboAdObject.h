//
//  TurboAdObject.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class TurboAdPlacementModel;
@class TurboAdUnitModel;

/// 广告对象 - 代表一个已加载的广告实例
@interface TurboAdObject : NSObject

@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, strong, nullable) TurboAdPlacementModel *placementModel;
@property (nonatomic, strong, nullable) TurboAdUnitModel *unitModel;
@property (nonatomic, assign) TurboAdFormat format;
@property (nonatomic, copy) NSString *requestID;
@property (nonatomic, strong, nullable) NSDate *expireDate;
@property (nonatomic, strong, nullable) id customObject;
@property (nonatomic, assign) double ecpm;
@property (nonatomic, assign) BOOL isShown;

/// 创建时间
@property (nonatomic, strong, readonly) NSDate *createTime;

/// 广告是否已过期
- (BOOL)isExpired;

/// 创建广告对象
+ (instancetype)adWithPlacementModel:(TurboAdPlacementModel *)placementModel
                           unitModel:(TurboAdUnitModel *)unitModel
                              format:(TurboAdFormat)format;

@end

NS_ASSUME_NONNULL_END
