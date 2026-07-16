#import "TurboBannerAdManager.h"
#import "TurboAdManager.h"
#import "TurboAdLoader.h"
#import "TurboTracker.h"

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
    [[TurboAdLoader sharedLoader] requestAdWithPlacementID:placementID extra:extra completion:^(NSDictionary * _Nullable offerDict, NSError * _Nullable error) {
        if (error) {
            if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
                [delegate didFailToLoadADWithPlacementID:placementID error:error];
            }
        } else if (offerDict) {
            NSMutableArray *cacheArray = self.adCache[placementID];
            if (!cacheArray) {
                cacheArray = [NSMutableArray array];
                self.adCache[placementID] = cacheArray;
            }
            [cacheArray addObject:offerDict];

            if ([delegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) {
                [delegate didFinishLoadingADWithPlacementID:placementID];
            }
        }
    }];
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

    [[TurboTracker sharedTracker] trackEvent:TurboTrackerEventImpression placementID:placementID adData:adData];

    TurboBannerView *bannerView = [[TurboBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [bannerView loadBannerAd];

    return bannerView;
}

@end
