//
//  TurboAdObject.m
//  TurboAdSDK
//

#import "TurboAdObject.h"
#import "TurboAdPlacementModel.h"
#import "TurboAdUnitModel.h"

@interface TurboAdObject ()
@property (nonatomic, strong, readwrite) NSDate *createTime;
@end

@implementation TurboAdObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _createTime = [NSDate date];
        _requestID = [[NSUUID UUID] UUIDString];
        _isShown = NO;
        _ecpm = 0;
    }
    return self;
}

+ (instancetype)adWithPlacementModel:(TurboAdPlacementModel *)placementModel
                           unitModel:(TurboAdUnitModel *)unitModel
                              format:(TurboAdFormat)format {
    TurboAdObject *ad = [[TurboAdObject alloc] init];
    ad.placementID = placementModel.placementID;
    ad.placementModel = placementModel;
    ad.unitModel = unitModel;
    ad.format = format;
    ad.ecpm = unitModel.price;
    return ad;
}

- (BOOL)isExpired {
    if (!self.expireDate) return NO;
    return [[NSDate date] compare:self.expireDate] == NSOrderedDescending;
}

@end
