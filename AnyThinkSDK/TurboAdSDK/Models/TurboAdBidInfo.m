//
//  TurboAdBidInfo.m
//  TurboAdSDK
//

#import "TurboAdBidInfo.h"

@implementation TurboAdBidInfo

+ (instancetype)infoWithDictionary:(NSDictionary *)dict placementID:(NSString *)placementID {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    TurboAdBidInfo *info = [[TurboAdBidInfo alloc] init];
    info.placementID = placementID;
    info.unitID = dict[@"unit_id"] ?: @"";
    info.price = [dict[@"price"] doubleValue];
    info.bidId = dict[@"bid_id"] ?: [[NSUUID UUID] UUIDString];
    info.winNoticeURL = dict[@"win_notice_url"];
    info.customObject = dict[@"custom_object"];
    
    NSTimeInterval expireTime = [dict[@"expire_time"] doubleValue];
    if (expireTime > 0) {
        info.expireDate = [NSDate dateWithTimeIntervalSince1970:expireTime];
    } else {
        // 默认 30 分钟过期
        info.expireDate = [NSDate dateWithTimeIntervalSinceNow:1800];
    }
    
    return info;
}

- (BOOL)isExpired {
    if (!self.expireDate) return NO;
    return [[NSDate date] compare:self.expireDate] == NSOrderedDescending;
}

@end
