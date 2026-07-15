//
//  TurboAdSplashAd.m
//  TurboAdSDK
//

#import "TurboAdSplashAd.h"
#import "TurboAdManager.h"
#import "TurboAdSplashManager.h"
#import "TurboAdObject.h"
#import "TurboAdConstants.h"
#import "TurboAdLogger.h"
#import "TurboAdUtils.h"
#import "TurboAdTracker.h"
#import "TurboAdCapsManager.h"

@interface TurboAdSplashAd () <TurboAdLoadingDelegate>
@property (nonatomic, copy, readwrite) NSString *placementID;
@property (nonatomic, assign, readwrite) BOOL isReady;
@property (nonatomic, strong, readwrite, nullable) UIView *zoomOutView;
@property (nonatomic, strong, nullable) TurboAdObject *currentAd;
@property (nonatomic, strong, nullable) UIView *containerView;
@property (nonatomic, strong) UIView *splashOverlayView;
@property (nonatomic, strong) UIButton *skipButton;
@end

@implementation TurboAdSplashAd

- (instancetype)initWithPlacementID:(NSString *)placementID {
    self = [super init];
    if (self) {
        _placementID = [placementID copy];
        _isReady = NO;
    }
    return self;
}

- (void)loadAd {
    [self loadAdWithContainerView:nil];
}

- (void)loadAdWithContainerView:(UIView *)containerView {
    self.containerView = containerView;
    [[TurboAdManager sharedManager] loadADWithPlacementID:self.placementID
                                                   extra:nil
                                                delegate:self];
}

- (BOOL)showInWindow:(UIWindow *)window {
    return [self showInWindow:window bottomView:nil];
}

- (BOOL)showInWindow:(UIWindow *)window bottomView:(UIView *)bottomView {
    if (!self.isReady) {
        TurboLogError(@"Splash not ready for placement: %@", self.placementID);
        NSError *error = [NSError errorWithDomain:kTurboAdErrorDomain
                                             code:TurboAdErrorCodeAdNotReady
                                         userInfo:@{NSLocalizedDescriptionKey: @"Splash ad is not ready"}];
        [TurboAdUtils runOnMainThread:^{
            if ([self.delegate respondsToSelector:@selector(splashDidFailToShowForPlacementID:error:)]) {
                [self.delegate splashDidFailToShowForPlacementID:self.placementID error:error];
            }
        }];
        return NO;
    }
    
    if (![[TurboAdCapsManager sharedManager] canShowWithPlacementID:self.placementID]) {
        TurboLogWarning(@"Splash show blocked by frequency cap: %@", self.placementID);
        return NO;
    }
    
    NSError *error = nil;
    self.currentAd = [[TurboAdManager sharedManager] offerWithPlacementID:self.placementID error:&error];
    if (!self.currentAd) {
        [TurboAdUtils runOnMainThread:^{
            if ([self.delegate respondsToSelector:@selector(splashDidFailToShowForPlacementID:error:)]) {
                [self.delegate splashDidFailToShowForPlacementID:self.placementID error:error];
            }
        }];
        return NO;
    }
    
    [[TurboAdManager sharedManager] markAdAsShown:self.currentAd];
    
    TurboLogInfo(@"Showing splash for placement: %@", self.placementID);
    
    // 创建全屏覆盖视图
    [TurboAdUtils runOnMainThread:^{
        [self showSplashOverlayInWindow:window bottomView:bottomView];
    }];
    
    return YES;
}

- (void)showSplashOverlayInWindow:(UIWindow *)window bottomView:(UIView *)bottomView {
    self.splashOverlayView = [[UIView alloc] initWithFrame:window.bounds];
    self.splashOverlayView.backgroundColor = [UIColor whiteColor];
    self.splashOverlayView.tag = 99999;
    
    // 广告内容区域（占屏幕约 75%）
    CGFloat adHeight = window.bounds.size.height * 0.75;
    UIView *adContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, window.bounds.size.width, adHeight)];
    adContentView.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    [self.splashOverlayView addSubview:adContentView];
    
    // 广告标签
    UILabel *adLabel = [[UILabel alloc] initWithFrame:adContentView.bounds];
    adLabel.textAlignment = NSTextAlignmentCenter;
    adLabel.text = @"Splash Ad";
    adLabel.textColor = [UIColor whiteColor];
    adLabel.font = [UIFont boldSystemFontOfSize:24];
    [adContentView addSubview:adLabel];
    
    // 跳过按钮
    self.skipButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.skipButton.frame = CGRectMake(window.bounds.size.width - 70, 50, 60, 30);
    [self.skipButton setTitle:@"跳过" forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.skipButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.skipButton.layer.cornerRadius = 15;
    self.skipButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.skipButton addTarget:self action:@selector(skipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.splashOverlayView addSubview:self.skipButton];
    
    // 底部保留区域
    if (bottomView) {
        bottomView.frame = CGRectMake(0, adHeight, window.bounds.size.width, window.bounds.size.height - adHeight);
        [self.splashOverlayView addSubview:bottomView];
    }
    
    [window addSubview:self.splashOverlayView];
    
    // 通知展示
    if ([self.delegate respondsToSelector:@selector(splashDidShowForPlacementID:)]) {
        [self.delegate splashDidShowForPlacementID:self.placementID];
    }
    
    // 5 秒后自动关闭
    [TurboAdUtils runAfterDelay:5.0 block:^{
        [self dismissSplash];
    }];
}

- (void)skipButtonTapped {
    [self dismissSplash];
}

- (void)dismissSplash {
    [UIView animateWithDuration:0.3 animations:^{
        self.splashOverlayView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.splashOverlayView removeFromSuperview];
        self.splashOverlayView = nil;
        
        if ([self.delegate respondsToSelector:@selector(splashDidCloseForPlacementID:)]) {
            [self.delegate splashDidCloseForPlacementID:self.placementID];
        }
    }];
}

#pragma mark - TurboAdLoadingDelegate

- (void)didFinishLoadingAdWithPlacementID:(NSString *)placementID {
    self.isReady = YES;
    TurboLogDebug(@"Splash loaded: %@", placementID);
}

- (void)didFailToLoadAdWithPlacementID:(NSString *)placementID error:(NSError *)error {
    self.isReady = NO;
    TurboLogDebug(@"Splash load failed: %@, error: %@", placementID, error.localizedDescription);
}

@end
