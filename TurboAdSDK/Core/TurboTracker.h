#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TurboTrackerEvent) {
    TurboTrackerEventImpression = 0,
    TurboTrackerEventClick = 1,
    TurboTrackerEventClose = 2,
    TurboTrackerEventVideoStart = 3,
    TurboTrackerEventVideoEnd = 4,
    TurboTrackerEventRewarded = 5
};

@interface TurboTracker : NSObject

+ (instancetype)sharedTracker;

- (void)trackEvent:(TurboTrackerEvent)event placementID:(NSString *)placementID adData:(nullable NSDictionary *)adData;

@end

NS_ASSUME_NONNULL_END
