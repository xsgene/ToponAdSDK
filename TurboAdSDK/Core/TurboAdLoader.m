#import "TurboAdLoader.h"

@implementation TurboAdLoader

+ (instancetype)sharedLoader {
    static TurboAdLoader *sharedLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLoader = [[self alloc] init];
    });
    return sharedLoader;
}

- (void)requestAdWithPlacementID:(NSString *)placementID
                           extra:(NSDictionary *)extra
                      completion:(void(^)(NSDictionary *offerDict, NSError *error))completion {

    // Simulate network request via dispatch_after
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (placementID.length == 0) {
            NSError *error = [NSError errorWithDomain:@"TurboAdSDK" code:-1001 userInfo:@{NSLocalizedDescriptionKey: @"Invalid placement ID"}];
            if (completion) completion(nil, error);
            return;
        }

        // Mock a successful JSON response
        NSDictionary *mockResponse = @{
            @"placement_id": placementID,
            @"ad_id": [NSString stringWithFormat:@"mock_ad_%lu", (unsigned long)arc4random()],
            @"title": [NSString stringWithFormat:@"Turbo Ad %lu", (unsigned long)arc4random_uniform(100)],
            @"body": @"This is a downloaded mock ad from the server.",
            @"expire_timestamp": @([[NSDate date] timeIntervalSince1970] + 3600)
        };

        NSLog(@"TurboAdLoader: Successfully downloaded ad for placement: %@", placementID);
        if (completion) completion(mockResponse, nil);
    });
}

@end
