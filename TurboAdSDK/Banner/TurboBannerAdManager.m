#import "TurboBannerAdManager.h"
#import "TurboAdManager.h"

@interface TurboBannerAdManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSDictionary *> *> *adCache;
@end

@implementation TurboBannerAdManager

+ (instancetype)sharedManager {
    static TurboBannerAdManager *sharedManager = nil;
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

- (void)loadBannerAdWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra delegate:(id<TurboBannerDelegate>)delegate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (placementID.length > 0) {
            NSDictionary *mockAdData = @{@"banner_id": [NSString stringWithFormat:@"banner_%f", [[NSDate date] timeIntervalSince1970]]};

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

- (TurboBannerView *)getBannerViewWithPlacementID:(NSString *)placementID {
    if (![self isReadyForPlacementID:placementID]) {
        NSLog(@"Banner Ad is not ready for placement ID: %@", placementID);
        return nil;
    }

    // Consume from cache
    NSMutableArray *cacheArray = self.adCache[placementID];
    NSDictionary *adData = [cacheArray firstObject];
    [cacheArray removeObjectAtIndex:0];

    NSLog(@"Generating banner view for data: %@", adData);

    TurboBannerView *bannerView = [[TurboBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [bannerView loadBannerAd];

    return bannerView;
}

@end
