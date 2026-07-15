//
//  TurboAdBannerView.m
//  TurboAdSDK
//

#import "TurboAdBannerView.h"
#import "TurboAdManager.h"
#import "TurboAdBannerManager.h"
#import "TurboAdObject.h"
#import "TurboAdConstants.h"
#import "TurboAdLogger.h"
#import "TurboAdUtils.h"
#import "TurboAdTracker.h"
#import "TurboAdCapsManager.h"
#import "TurboAdPlacementManager.h"
#import "TurboAdPlacementModel.h"

static const NSTimeInterval kDefaultAutoRefreshInterval = 30.0;

@interface TurboAdBannerView () <TurboAdLoadingDelegate>
@property (nonatomic, copy, readwrite) NSString *placementID;
@property (nonatomic, assign, readwrite) BOOL isAutoRefreshing;
@property (nonatomic, strong, nullable) NSTimer *refreshTimer;
@property (nonatomic, assign) NSTimeInterval autoRefreshInterval;
@property (nonatomic, strong, nullable) TurboAdObject *currentAd;
@property (nonatomic, strong) UILabel *adLabel;
@end

@implementation TurboAdBannerView

- (instancetype)initWithFrame:(CGRect)frame placementID:(NSString *)placementID {
    self = [super initWithFrame:frame];
    if (self) {
        _placementID = [placementID copy];
        _autoRefreshInterval = kDefaultAutoRefreshInterval;
        _isAutoRefreshing = NO;
        [self setupUI];
    }
    return self;
}

- (void)dealloc {
    [self stopAutoRefresh];
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    self.layer.borderWidth = 0.5;
    self.clipsToBounds = YES;
    
    _adLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _adLabel.textAlignment = NSTextAlignmentCenter;
    _adLabel.font = [UIFont systemFontOfSize:14];
    _adLabel.textColor = [UIColor grayColor];
    _adLabel.text = @"Banner Ad";
    _adLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_adLabel];
    
    // 添加关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(self.bounds.size.width - 24, 2, 22, 22);
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    closeButton.tintColor = [UIColor grayColor];
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
}

- (void)loadAd {
    [[TurboAdManager sharedManager] loadADWithPlacementID:self.placementID
                                                   extra:nil
                                                delegate:self];
}

- (void)startAutoRefresh {
    if (self.isAutoRefreshing) return;
    self.isAutoRefreshing = YES;
    
    [self stopAutoRefresh];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoRefreshInterval
                                                        target:self
                                                      selector:@selector(autoRefreshFired)
                                                      userInfo:nil
                                                       repeats:YES];
    TurboLogDebug(@"Banner auto refresh started for: %@, interval: %.1fs", self.placementID, self.autoRefreshInterval);
}

- (void)stopAutoRefresh {
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    self.isAutoRefreshing = NO;
}

- (void)setAutoRefreshInterval:(NSTimeInterval)interval {
    _autoRefreshInterval = MAX(interval, 15.0); // 最小 15 秒
    
    // 如果正在刷新，重启定时器
    if (self.isAutoRefreshing) {
        [self stopAutoRefresh];
        [self startAutoRefresh];
    }
}

- (void)autoRefreshFired {
    TurboLogDebug(@"Banner auto refresh fired for: %@", self.placementID);
    [self loadAd];
}

- (void)closeButtonTapped {
    if ([self.delegate respondsToSelector:@selector(bannerViewDidTapCloseButton:)]) {
        [self.delegate bannerViewDidTapCloseButton:self];
    }
    
    [self stopAutoRefresh];
    self.hidden = YES;
    
    if ([self.delegate respondsToSelector:@selector(bannerViewDidClose:)]) {
        [self.delegate bannerViewDidClose:self];
    }
}

#pragma mark - TurboAdLoadingDelegate

- (void)didFinishLoadingAdWithPlacementID:(NSString *)placementID {
    [TurboAdUtils runOnMainThread:^{
        self.adLabel.text = @"Ad Loaded";
        self.adLabel.textColor = [UIColor greenColor];
        
        if ([self.delegate respondsToSelector:@selector(bannerViewDidLoad:)]) {
            [self.delegate bannerViewDidLoad:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(bannerViewDidShow:)]) {
            [self.delegate bannerViewDidShow:self];
        }
    }];
}

- (void)didFailToLoadAdWithPlacementID:(NSString *)placementID error:(NSError *)error {
    [TurboAdUtils runOnMainThread:^{
        self.adLabel.text = @"No Ad";
        self.adLabel.textColor = [UIColor redColor];
        
        if (self.isAutoRefreshing) {
            if ([self.delegate respondsToSelector:@selector(bannerView:didFailToAutoRefreshWithError:)]) {
                [self.delegate bannerView:self didFailToAutoRefreshWithError:error];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(bannerView:didFailWithError:)]) {
                [self.delegate bannerView:self didFailWithError:error];
            }
        }
    }];
}

@end
