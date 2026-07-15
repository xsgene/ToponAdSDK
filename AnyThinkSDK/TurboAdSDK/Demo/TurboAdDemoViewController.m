//
//  TurboAdDemoViewController.m
//  TurboAdSDK
//

#import "TurboAdDemoViewController.h"
#import "TurboAdSDK.h"

// 替换为你的实际 Placement ID
static NSString * const kRewardedVideoPlacementID = @"b65a3f5c8d2e4f";
static NSString * const kInterstitialPlacementID = @"b65a3f5c8d2e50";
static NSString * const kBannerPlacementID = @"b65a3f5c8d2e51";
static NSString * const kSplashPlacementID = @"b65a3f5c8d2e52";
static NSString * const kNativePlacementID = @"b65a3f5c8d2e53";

@interface TurboAdDemoViewController () <
    TurboAdRewardedVideoDelegate,
    TurboAdInterstitialDelegate,
    TurboAdBannerDelegate,
    TurboAdSplashDelegate,
    TurboAdNativeDelegate
>

@property (nonatomic, strong) TurboAdRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) TurboAdInterstitialAd *interstitialAd;
@property (nonatomic, strong) TurboAdBannerView *bannerView;
@property (nonatomic, strong) TurboAdSplashAd *splashAd;
@property (nonatomic, strong) TurboAdNativeView *nativeAdView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *buttonStack;

@end

@implementation TurboAdDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TurboAdSDK Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    [self initializeSDK];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
    
    self.buttonStack = [[UIStackView alloc] init];
    self.buttonStack.axis = UILayoutConstraintAxisVertical;
    self.buttonStack.spacing = 12;
    self.buttonStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.buttonStack];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.buttonStack.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:20],
        [self.buttonStack.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:20],
        [self.buttonStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-20],
    ]];
    
    [self addButtonWithTitle:@"1. 初始化 SDK" action:@selector(initSDKAction)];
    [self addButtonWithTitle:@"2. 加载激励视频" action:@selector(loadRewardedVideo)];
    [self addButtonWithTitle:@"3. 展示激励视频" action:@selector(showRewardedVideo)];
    [self addButtonWithTitle:@"4. 加载插屏广告" action:@selector(loadInterstitial)];
    [self addButtonWithTitle:@"5. 展示插屏广告" action:@selector(showInterstitial)];
    [self addButtonWithTitle:@"6. 加载横幅广告" action:@selector(loadBanner)];
    [self addButtonWithTitle:@"7. 加载开屏广告" action:@selector(loadSplash)];
    [self addButtonWithTitle:@"8. 展示开屏广告" action:@selector(showSplash)];
    [self addButtonWithTitle:@"9. 加载原生广告" action:@selector(loadNative)];
}

- (void)addButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 8;
    button.heightAnchor.constraintEqualToConstant:44].active = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.buttonStack addArrangedSubview:button];
}

#pragma mark - SDK 初始化

- (void)initializeSDK {
    TurboAdSDKConfig *config = [TurboAdSDKConfig configWithAppID:@"your_app_id" appKey:@"your_app_key"];
    config.logLevel = TurboAdLogLevelDebug;
    config.testMode = YES;
    
    [[TurboAdSDKCore sharedCore] initializeWithConfig:config completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"SDK initialized successfully!");
        } else {
            NSLog(@"SDK initialization failed: %@", error.localizedDescription);
        }
    }];
}

- (void)initSDKAction {
    [self initializeSDK];
}

#pragma mark - 激励视频

- (void)loadRewardedVideo {
    self.rewardedVideoAd = [[TurboAdRewardedVideoAd alloc] initWithPlacementID:kRewardedVideoPlacementID];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAd];
    NSLog(@"Loading rewarded video...");
}

- (void)showRewardedVideo {
    if ([self.rewardedVideoAd isReady]) {
        [self.rewardedVideoAd showFromViewController:self scene:@"demo_scene"];
    } else {
        NSLog(@"Rewarded video not ready, please load first.");
        [self showAlert:@"提示" message:@"激励视频未就绪，请先加载"];
    }
}

#pragma mark - TurboAdRewardedVideoDelegate

- (void)rewardedVideoDidStartPlayingForPlacementID:(NSString *)placementID {
    NSLog(@"Rewarded video started playing: %@", placementID);
}

- (void)rewardedVideoDidEndPlayingForPlacementID:(NSString *)placementID {
    NSLog(@"Rewarded video ended: %@", placementID);
}

- (void)rewardedVideoDidCloseForPlacementID:(NSString *)placementID rewarded:(BOOL)rewarded {
    NSLog(@"Rewarded video closed: %@, rewarded: %@", placementID, rewarded ? @"YES" : @"NO");
    if (rewarded) {
        [self showAlert:@"恭喜" message:@"获得奖励！"];
    }
}

- (void)rewardedVideoDidRewardSuccessForPlacementID:(NSString *)placementID {
    NSLog(@"Rewarded success: %@", placementID);
}

- (void)rewardedVideoDidClickForPlacementID:(NSString *)placementID {
    NSLog(@"Rewarded video clicked: %@", placementID);
}

#pragma mark - 插屏广告

- (void)loadInterstitial {
    self.interstitialAd = [[TurboAdInterstitialAd alloc] initWithPlacementID:kInterstitialPlacementID];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
    NSLog(@"Loading interstitial...");
}

- (void)showInterstitial {
    if ([self.interstitialAd isReady]) {
        [self.interstitialAd showFromViewController:self scene:@"demo_scene"];
    } else {
        NSLog(@"Interstitial not ready, please load first.");
        [self showAlert:@"提示" message:@"插屏广告未就绪，请先加载"];
    }
}

#pragma mark - TurboAdInterstitialDelegate

- (void)interstitialDidShowForPlacementID:(NSString *)placementID {
    NSLog(@"Interstitial shown: %@", placementID);
}

- (void)interstitialDidCloseForPlacementID:(NSString *)placementID {
    NSLog(@"Interstitial closed: %@", placementID);
}

- (void)interstitialDidClickForPlacementID:(NSString *)placementID {
    NSLog(@"Interstitial clicked: %@", placementID);
}

#pragma mark - 横幅广告

- (void)loadBanner {
    self.bannerView = [[TurboAdBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)
                                                 placementID:kBannerPlacementID];
    self.bannerView.delegate = self;
    self.bannerView.center = CGPointMake(self.view.center.x, self.view.bounds.size.height - 80);
    [self.view addSubview:self.bannerView];
    [self.bannerView loadAd];
    NSLog(@"Loading banner...");
}

#pragma mark - TurboAdBannerDelegate

- (void)bannerViewDidLoad:(TurboAdBannerView *)bannerView {
    NSLog(@"Banner loaded");
}

- (void)bannerView:(TurboAdBannerView *)bannerView didFailWithError:(NSError *)error {
    NSLog(@"Banner load failed: %@", error.localizedDescription);
}

- (void)bannerViewDidClick:(TurboAdBannerView *)bannerView {
    NSLog(@"Banner clicked");
}

#pragma mark - 开屏广告

- (void)loadSplash {
    self.splashAd = [[TurboAdSplashAd alloc] initWithPlacementID:kSplashPlacementID];
    self.splashAd.delegate = self;
    [self.splashAd loadAd];
    NSLog(@"Loading splash...");
}

- (void)showSplash {
    if (self.splashAd.isReady) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        [self.splashAd showInWindow:window];
    } else {
        NSLog(@"Splash not ready, please load first.");
        [self showAlert:@"提示" message:@"开屏广告未就绪，请先加载"];
    }
}

#pragma mark - TurboAdSplashDelegate

- (void)splashDidShowForPlacementID:(NSString *)placementID {
    NSLog(@"Splash shown: %@", placementID);
}

- (void)splashDidCloseForPlacementID:(NSString *)placementID {
    NSLog(@"Splash closed: %@", placementID);
}

- (void)splashDidClickForPlacementID:(NSString *)placementID {
    NSLog(@"Splash clicked: %@", placementID);
}

#pragma mark - 原生广告

- (void)loadNative {
    self.nativeAdView = [[TurboAdNativeView alloc] initWithFrame:CGRectMake(20, 300, self.view.bounds.size.width - 40, 200)
                                                    placementID:kNativePlacementID];
    self.nativeAdView.delegate = self;
    [self.view addSubview:self.nativeAdView];
    [self.nativeAdView loadAd];
    NSLog(@"Loading native ad...");
}

#pragma mark - TurboAdNativeDelegate

- (void)nativeAdDidLoadForPlacementID:(NSString *)placementID {
    NSLog(@"Native ad loaded: %@", placementID);
}

- (void)nativeAdDidFailToLoadForPlacementID:(NSString *)placementID error:(NSError *)error {
    NSLog(@"Native ad load failed: %@, error: %@", placementID, error.localizedDescription);
}

- (void)nativeAdDidShowForPlacementID:(NSString *)placementID {
    NSLog(@"Native ad shown: %@", placementID);
}

- (void)nativeAdDidClickForPlacementID:(NSString *)placementID {
    NSLog(@"Native ad clicked: %@", placementID);
}

#pragma mark - Helpers

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
