#import "TurboAPI.h"

@interface TurboAPI ()
@property (nonatomic, copy, readwrite) NSString *appID;
@property (nonatomic, copy, readwrite) NSString *appKey;
@end

@implementation TurboAPI

+ (instancetype)sharedInstance {
    static TurboAPI *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)startWithAppID:(NSString *)appID appKey:(NSString *)appKey error:(NSError **)error {
    if (appID.length == 0 || appKey.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"TurboAdSDK" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"App ID and App Key cannot be empty."}];
        }
        return NO;
    }

    self.appID = appID;
    self.appKey = appKey;

    // Perform initialization logic here
    NSLog(@"TurboAdSDK initialized with AppID: %@, AppKey: %@", self.appID, self.appKey);
    return YES;
}

@end
