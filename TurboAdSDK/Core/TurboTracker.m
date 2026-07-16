#import "TurboTracker.h"

@implementation TurboTracker

+ (instancetype)sharedTracker {
    static TurboTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[self alloc] init];
    });
    return sharedTracker;
}

- (void)trackEvent:(TurboTrackerEvent)event placementID:(NSString *)placementID adData:(NSDictionary *)adData {
    NSString *eventName = @"Unknown";
    switch (event) {
        case TurboTrackerEventImpression: eventName = @"Impression"; break;
        case TurboTrackerEventClick: eventName = @"Click"; break;
        case TurboTrackerEventClose: eventName = @"Close"; break;
        case TurboTrackerEventVideoStart: eventName = @"VideoStart"; break;
        case TurboTrackerEventVideoEnd: eventName = @"VideoEnd"; break;
        case TurboTrackerEventRewarded: eventName = @"Rewarded"; break;
    }

    NSString *adId = adData[@"ad_id"] ?: @"unknown_ad_id";

    // Simulate async network request to tracking endpoint
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"TurboTracker: Sending tracking event [%@] for placement [%@] and ad [%@]", eventName, placementID, adId);
        // Simulate a network delay for sending tracking ping
        [NSThread sleepForTimeInterval:0.2];
        NSLog(@"TurboTracker: Tracking event [%@] successfully recorded by server.", eventName);
    });
}

@end
