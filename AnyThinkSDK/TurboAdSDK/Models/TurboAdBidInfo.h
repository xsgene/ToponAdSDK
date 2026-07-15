//
//  TurboAdBidInfo.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 竞价信息模型
@interface TurboAdBidInfo : NSObject

@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, copy) NSString *unitID;
@property (nonatomic, assign) double price;
@property (nonatomic, copy) NSString *bidId;
@property (nonatomic, strong, nullable) NSDate *expireDate;
@property (nonatomic, strong, nullable) id customObject;
@property (nonatomic, copy, nullable) NSString *winNoticeURL;

/// 竞价是否已过期
- (BOOL)isExpired;

/// 从字典初始化
+ (instancetype)infoWithDictionary:(NSDictionary *)dict placementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
