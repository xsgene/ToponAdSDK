//
//  TurboAdUnitModel.m
//  TurboAdSDK
//

#import "TurboAdUnitModel.h"

@implementation TurboAdUnitModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    TurboAdUnitModel *model = [[TurboAdUnitModel alloc] init];
    model.unitID = dict[@"unit_id"] ?: @"";
    model.networkFirmID = [dict[@"network_firm_id"] integerValue];
    model.adapterClassName = dict[@"adapter_class"] ?: @"";
    model.networkTimeout = [dict[@"network_timeout"] doubleValue] > 0 ? [dict[@"network_timeout"] doubleValue] : 30.0;
    model.price = [dict[@"price"] doubleValue];
    model.ecpmLevel = [dict[@"ecpm_level"] integerValue];
    model.isHeaderBidding = [dict[@"is_header_bidding"] boolValue];
    model.networkCustomInfo = dict[@"network_custom_info"];
    
    return model;
}

@end
