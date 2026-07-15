//
//  TurboAdCapsManager.m
//  TurboAdSDK
//

#import "TurboAdCapsManager.h"
#import "TurboAdThreadSafe.h"
#import "TurboAdStorage.h"
#import "TurboAdLogger.h"

@interface TurboAdCapsRecord : NSObject
@property (nonatomic, assign) NSInteger loadCountToday;
@property (nonatomic, assign) NSInteger loadCountThisHour;
@property (nonatomic, assign) NSInteger showCountToday;
@property (nonatomic, assign) NSInteger showCountThisHour;
@property (nonatomic, assign) NSTimeInterval lastLoadTime;
@property (nonatomic, assign) NSTimeInterval lastShowTime;
@property (nonatomic, assign) NSInteger currentDay;
@property (nonatomic, assign) NSInteger currentHour;
@end

@implementation TurboAdCapsRecord
- (instancetype)init {
    self = [super init];
    if (self) {
        _loadCountToday = 0;
        _loadCountThisHour = 0;
        _showCountToday = 0;
        _showCountThisHour = 0;
        _lastLoadTime = 0;
        _lastShowTime = 0;
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitHour fromDate:[NSDate date]];
        _currentDay = comps.day;
        _currentHour = comps.hour;
    }
    return self;
}

- (void)refreshIfNeeded {
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitHour fromDate:[NSDate date]];
    if (comps.day != self.currentDay) {
        self.loadCountToday = 0;
        self.showCountToday = 0;
        self.currentDay = comps.day;
    }
    if (comps.hour != self.currentHour) {
        self.loadCountThisHour = 0;
        self.showCountThisHour = 0;
        self.currentHour = comps.hour;
    }
}
@end

@interface TurboAdCapsConfig : NSObject
@property (nonatomic, assign) NSTimeInterval pacing;
@property (nonatomic, assign) NSInteger capByDay;
@property (nonatomic, assign) NSInteger capByHour;
@end

@implementation TurboAdCapsConfig
@end

@interface TurboAdCapsManager ()
@property (nonatomic, strong) TurboAdThreadSafeDictionary *records; // placementID -> TurboAdCapsRecord
@property (nonatomic, strong) TurboAdThreadSafeDictionary *configs; // placementID -> TurboAdCapsConfig
@end

@implementation TurboAdCapsManager

+ (instancetype)sharedManager {
    static TurboAdCapsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _records = [[TurboAdThreadSafeDictionary alloc] initWithQueueLabel:@"com.turboadsdk.caps.records"];
        _configs = [[TurboAdThreadSafeDictionary alloc] initWithQueueLabel:@"com.turboadsdk.caps.configs"];
    }
    return self;
}

- (BOOL)canLoadWithPlacementID:(NSString *)placementID {
    TurboAdCapsConfig *config = [self.configs objectForKey:placementID];
    if (!config) return YES;
    
    TurboAdCapsRecord *record = [self.records objectForKey:placementID];
    if (!record) return YES;
    
    [record refreshIfNeeded];
    
    // 检查 pacing
    if (config.pacing > 0 && record.lastLoadTime > 0) {
        NSTimeInterval elapsed = [[NSDate date] timeIntervalSince1970] - record.lastLoadTime;
        if (elapsed < config.pacing) {
            TurboLogDebug(@"Load blocked by pacing for: %@, remaining: %.1fs", placementID, config.pacing - elapsed);
            return NO;
        }
    }
    
    // 检查每日上限
    if (config.capByDay > 0 && record.loadCountToday >= config.capByDay) {
        TurboLogDebug(@"Load blocked by daily cap for: %@", placementID);
        return NO;
    }
    
    // 检查每小时上限
    if (config.capByHour > 0 && record.loadCountThisHour >= config.capByHour) {
        TurboLogDebug(@"Load blocked by hourly cap for: %@", placementID);
        return NO;
    }
    
    return YES;
}

- (BOOL)canShowWithPlacementID:(NSString *)placementID {
    TurboAdCapsConfig *config = [self.configs objectForKey:placementID];
    if (!config) return YES;
    
    TurboAdCapsRecord *record = [self.records objectForKey:placementID];
    if (!record) return YES;
    
    [record refreshIfNeeded];
    
    if (config.pacing > 0 && record.lastShowTime > 0) {
        NSTimeInterval elapsed = [[NSDate date] timeIntervalSince1970] - record.lastShowTime;
        if (elapsed < config.pacing) {
            return NO;
        }
    }
    
    if (config.capByDay > 0 && record.showCountToday >= config.capByDay) {
        return NO;
    }
    
    if (config.capByHour > 0 && record.showCountThisHour >= config.capByHour) {
        return NO;
    }
    
    return YES;
}

- (void)recordLoadWithPlacementID:(NSString *)placementID {
    TurboAdCapsRecord *record = [self.records objectForKey:placementID];
    if (!record) {
        record = [[TurboAdCapsRecord alloc] init];
        [self.records setObject:record forKey:placementID];
    }
    
    [record refreshIfNeeded];
    record.loadCountToday++;
    record.loadCountThisHour++;
    record.lastLoadTime = [[NSDate date] timeIntervalSince1970];
}

- (void)recordShowWithPlacementID:(NSString *)placementID {
    TurboAdCapsRecord *record = [self.records objectForKey:placementID];
    if (!record) {
        record = [[TurboAdCapsRecord alloc] init];
        [self.records setObject:record forKey:placementID];
    }
    
    [record refreshIfNeeded];
    record.showCountToday++;
    record.showCountThisHour++;
    record.lastShowTime = [[NSDate date] timeIntervalSince1970];
}

- (void)setPacing:(NSTimeInterval)pacing
          capByDay:(NSInteger)capByDay
         capByHour:(NSInteger)capByHour
   forPlacementID:(NSString *)placementID {
    TurboAdCapsConfig *config = [[TurboAdCapsConfig alloc] init];
    config.pacing = pacing;
    config.capByDay = capByDay;
    config.capByHour = capByHour;
    [self.configs setObject:config forKey:placementID];
    TurboLogDebug(@"Caps config set for: %@ (pacing: %.1f, day: %ld, hour: %ld)", placementID, pacing, (long)capByDay, (long)capByHour);
}

- (void)resetRecordsWithPlacementID:(NSString *)placementID {
    [self.records removeObjectForKey:placementID];
}

@end