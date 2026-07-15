#import "TurboNativeAdManager.h"
#import "TurboAdManager.h"

@interface TurboNativeAdManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSDictionary *> *> *adCache;
@end

@implementation TurboNativeAdManager

+ (instancetype)sharedManager {
    static TurboNativeAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _adCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadNativeAdWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboNativeDelegate>)delegate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (placementID.length > 0) {
            NSDictionary *mockAdData = @{
                @"title": [NSString stringWithFormat:@"Native Title %ld", (long)arc4random_uniform(100)],
                @"body": @"This is a mock native ad body loaded from TurboAdSDK."
            };

            NSMutableArray *cacheArray = self.adCache[placementID];
            if (!cacheArray) {
                cacheArray = [NSMutableArray array];
                self.adCache[placementID] = cacheArray;
            }
            [cacheArray addObject:mockAdData];

            if ([delegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) {
                [delegate didFinishLoadingADWithPlacementID:placementID];
            }
        } else {
            if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
                NSError *error = [NSError errorWithDomain:@"TurboAdSDK" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid placement ID"}];
                [delegate didFailToLoadADWithPlacementID:placementID error:error];
            }
        }
    });
}

- (BOOL)isReadyForPlacementID:(NSString *)placementID {
    NSMutableArray *cacheArray = self.adCache[placementID];
    return cacheArray && cacheArray.count > 0;
}

- (TurboNativeAdView *)getNativeAdViewWithPlacementID:(NSString *)placementID {
    if (![self isReadyForPlacementID:placementID]) {
        NSLog(@"Native Ad is not ready for placement ID: %@", placementID);
        return nil;
    }

    // Consume from cache
    NSMutableArray *cacheArray = self.adCache[placementID];
    NSDictionary *adData = [cacheArray firstObject];
    [cacheArray removeObjectAtIndex:0];

    TurboNativeAdView *adView = [[TurboNativeAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    adView.titleLabel.text = adData[@"title"];
    adView.bodyLabel.text = adData[@"body"];
    [adView.callToActionButton setTitle:@"Click Me" forState:UIControlStateNormal];

    return adView;
}

@end
