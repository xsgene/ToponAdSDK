//
//  TurboAdUnitModel.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 广告单元模型 - 代表一个广告源配置
@interface TurboAdUnitModel : NSObject

@property (nonatomic, copy) NSString *unitID;
@property (nonatomic, assign) NSInteger networkFirmID;
@property (nonatomic, copy) NSString *adapterClassName;
@property (nonatomic, assign) NSTimeInterval networkTimeout;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) NSInteger ecpmLevel;
@property (nonatomic, assign) BOOL isHeaderBidding;
@property (nonatomic, copy, nullable) NSDictionary *networkCustomInfo;

/// 从字典初始化
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
