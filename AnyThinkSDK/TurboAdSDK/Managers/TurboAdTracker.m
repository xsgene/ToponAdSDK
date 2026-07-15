//
//  TurboAdTracker.m
//  TurboAdSDK
//

#import "TurboAdTracker.h"
#import "TurboAdObject.h"
#import "TurboAdSDKCore.h"
#import "TurboAdNetworking.h"
#import "TurboAdLogger.h"
#import "TurboAdUtils.h"
#import "TurboAdConstants.h"

@interface TurboAdTracker ()
@property (nonatomic, strong) NSMutableArray *eventQueue;
@property (nonatomic, strong) dispatch_queue_t processQueue;
@end

@implementation TurboAdTracker

+ (instancetype)sharedTracker {
    static TurboAdTracker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _eventQueue = [NSMutableArray array];
        _processQueue = dispatch_queue_create("com.turboadsdk.tracker", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)trackLoadStartWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra {
    [self trackEvent:@"load_start" placementID:placementID parameters:extra];
}

- (void)trackLoadSuccessWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject {
    NSDictionary *params = @{
        @"unit_id": adObject.unitModel.unitID ?: @"",
        @"ecpm": @(adObject.ecpm),
        @"request_id": adObject.requestID ?: @""
    };
    [self trackEvent:@"load_success" placementID:placementID parameters:params];
}

- (void)trackLoadFailureWithPlacementID:(NSString *)placementID error:(NSError *)error {
    NSDictionary *params = @{
        @"error_code": @(error.code),
        @"error_msg": error.localizedDescription ?: @""
    };
    [self trackEvent:@"load_fail" placementID:placementID parameters:params];
}

- (void)trackShowWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject {
    NSDictionary *params = @{
        @"unit_id": adObject.unitModel.unitID ?: @"",
        @"request_id": adObject.requestID ?: @""
    };
    [self trackEvent:@"show" placementID:placementID parameters:params];
}

- (void)trackClickWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject {
    NSDictionary *params = @{
        @"unit_id": adObject.unitModel.unitID ?: @"",
        @"request_id": adObject.requestID ?: @""
    };
    [self trackEvent:@"click" placementID:placementID parameters:params];
}

- (void)trackCloseWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject {
    NSDictionary *params = @{
        @"unit_id": adObject.unitModel.unitID ?: @"",
        @"request_id": adObject.requestID ?: @""
    };
    [self trackEvent:@"close" placementID:placementID parameters:params];
}

- (void)trackVideoStartWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject {
    NSDictionary *params = @{
        @"unit_id": adObject.unitModel.unitID ?: @"",
        @"request_id": adObject.requestID ?: @""
    };
    [self trackEvent:@"video_start" placementID:placementID parameters:params];
}

- (void)trackVideoEndWithPlacementID:(NSString *)placementID adObject:(TurboAdObject *)adObject {
    NSDictionary *params = @{
        @"unit_id": adObject.unitModel.unitID ?: @"",
        @"request_id": adObject.requestID ?: @""
    };
    [self trackEvent:@"video_end" placementID:placementID parameters:params];
}

- (void)trackEvent:(NSString *)event placementID:(NSString *)placementID parameters:(NSDictionary *)parameters {
    dispatch_async(self.processQueue, ^{
        NSMutableDictionary *eventData = [NSMutableDictionary dictionary];
        eventData[@"event"] = event;
        eventData[@"placement_id"] = placementID ?: @"";
        eventData[@"timestamp"] = @([[NSDate date] timeIntervalSince1970] * 1000);
        eventData[@"device_id"] = [TurboAdSDKCore sharedCore].deviceID ?: @"";
        eventData[@"app_id"] = [TurboAdSDKCore sharedCore].config.appID ?: @"";
        eventData[@"sdk_version"] = kTurboAdSDKVersion;
        
        if (parameters) {
            [eventData addEntriesFromDictionary:parameters];
        }
        
        @synchronized (self.eventQueue) {
            [self.eventQueue addObject:[eventData copy]];
            
            // 批量发送（每 10 条或 30 秒发送一次）
            if (self.eventQueue.count >= 10) {
                [self flushEvents];
            }
        }
        
        TurboLogVerbose(@"Tracked event: %@ for placement: %@", event, placementID);
    });
}

- (void)flushEvents {
    NSArray *events = nil;
    @synchronized (self.eventQueue) {
        if (self.eventQueue.count == 0) return;
        events = [self.eventQueue copy];
        [self.eventQueue removeAllObjects];
    }
    
    TurboAdSDKCore *core = [TurboAdSDKCore sharedCore];
    NSString *baseURL = core.config.serverURL ?: @"https://api.turboadsdk.com";
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/track", baseURL];
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:@{@"events": events} error:nil];
    
    [[TurboAdNetworking sharedManager] POST:urlString
                                 parameters:nil
                                    headers:@{@"Content-Type": @"application/json"}
                                   bodyData:bodyData
                                 completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            TurboLogWarning(@"Failed to flush events: %@", error.localizedDescription);
            // 将事件放回队列
            @synchronized (self.eventQueue) {
                [self.eventQueue insertObjects:events atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, events.count)]];
            }
        } else {
            TurboLogDebug(@"Flushed %lu events", (unsigned long)events.count);
        }
    }];
}

@end
