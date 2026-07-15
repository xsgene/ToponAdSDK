//
//  TurboAdPlacementModel.m
//  TurboAdSDK
//

#import "TurboAdPlacementModel.h"
#import "TurboAdUnitModel.h"

@implementation TurboAdPlacementModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    TurboAdPlacementModel *model = [[TurboAdPlacementModel alloc] init];
    model.placementID = dict[@"placement_id"] ?: @"";
    model.format = [dict[@"format"] integerValue];
    model.showType = [dict[@"show_type"] integerValue];
    
    // Parse unit groups
    NSMutableArray<TurboAdUnitModel *> *unitGroups = [NSMutableArray array];
    NSArray *unitGroupDicts = dict[@"unit_groups"];
    if ([unitGroupDicts isKindOfClass:[NSArray class]]) {
        for (NSDictionary *unitDict in unitGroupDicts) {
            TurboAdUnitModel *unit = [TurboAdUnitModel modelWithDictionary:unitDict];
            if (unit) {
                [unitGroups addObject:unit];
            }
        }
    }
    model.unitGroups = [unitGroups copy];
    
    // Parse header bidding unit groups
    NSMutableArray<TurboAdUnitModel *> *hbUnitGroups = [NSMutableArray array];
    NSArray *hbUnitGroupDicts = dict[@"header_bidding_unit_groups"];
    if ([hbUnitGroupDicts isKindOfClass:[NSArray class]]) {
        for (NSDictionary *unitDict in hbUnitGroupDicts) {
            TurboAdUnitModel *unit = [TurboAdUnitModel modelWithDictionary:unitDict];
            if (unit) {
                unit.isHeaderBidding = YES;
                [hbUnitGroups addObject:unit];
            }
        }
    }
    model.headerBiddingUnitGroups = [hbUnitGroups copy];
    
    // Frequency control
    model.pacing = [dict[@"pacing"] doubleValue];
    model.capByDay = [dict[@"cap_by_day"] integerValue];
    model.capByHour = [dict[@"cap_by_hour"] integerValue];
    
    // Auto refresh
    model.isAutoRefresh = [dict[@"is_auto_refresh"] boolValue];
    model.autoRefreshInterval = [dict[@"auto_refresh_interval"] doubleValue] > 0 ? [dict[@"auto_refresh_interval"] doubleValue] : 30.0;
    
    // Max concurrent
    model.maxConcurrentRequestCount = [dict[@"max_concurrent"] integerValue] > 0 ? [dict[@"max_concurrent"] integerValue] : 3;
    
    // Request ID
    model.requestID = dict[@"request_id"] ?: [[NSUUID UUID] UUIDString];
    
    return model;
}

- (NSArray<TurboAdUnitModel *> *)allUnitGroups {
    NSMutableArray<TurboAdUnitModel *> *all = [NSMutableArray array];
    if (self.headerBiddingUnitGroups.count > 0) {
        [all addObjectsFromArray:self.headerBiddingUnitGroups];
    }
    if (self.unitGroups.count > 0) {
        [all addObjectsFromArray:self.unitGroups];
    }
    return [all copy];
}

@end
