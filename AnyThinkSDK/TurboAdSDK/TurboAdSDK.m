//
//  TurboAdSDK.m
//  TurboAdSDK
//

#import "TurboAdSDK.h"

static NSString * const TurboAdSDKErrorDomain = @"com.turboad.sdk";

@implementation TurboAdSDKConfig
+ (instancetype)configWithAppID:(NSString *)appID placementID:(NSString *)placementID {
    TurboAdSDKConfig *config = [[TurboAdSDKConfig alloc] init];
    config.appID = appID;
    config.placementID = placementID;
    return config;
}
@end

@interface TurboAdSDK () {
    TurboAdSDKConfig *_config;
}
@end

@implementation TurboAdSDK
+ (instancetype)sharedSDK {
    static TurboAdSDK *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)initializeWithConfig:(TurboAdSDKConfig *)config completion:(void (^)(BOOL, NSError * _Nullable))completion {
    if (!config || config.appID.length == 0 || config.placementID.length == 0) {
        NSError *error = [NSError errorWithDomain:TurboAdSDKErrorDomain
                                             code:TurboAdErrorCodeInvalidConfiguration
                                         userInfo:@{NSLocalizedDescriptionKey: @"App ID and placement ID are required."}];
        if (completion) {
            completion(NO, error);
        }
        if ([self.delegate respondsToSelector:@selector(turboAdSDKDidInitialize:success:error:)]) {
            [self.delegate turboAdSDKDidInitialize:self success:NO error:error];
        }
        return;
    }

    _config = config;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSError *error = nil;
        if (completion) {
            completion(YES, error);
        }
        if ([self.delegate respondsToSelector:@selector(turboAdSDKDidInitialize:success:error:)]) {
            [self.delegate turboAdSDKDidInitialize:self success:YES error:error];
        }
    });
}

- (TurboAdSDKConfig *)config {
    return _config;
}
@end


// --- Banner Ad ---
@implementation TurboAdBannerView {
    NSString *_placementID;
    UILabel *_titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame placementID:(NSString *)placementID {
    self = [super initWithFrame:frame];
    if (self) {
        _placementID = [placementID copy];
        self.backgroundColor = [UIColor colorWithRed:0.11 green:0.56 blue:0.95 alpha:1.0];
        self.layer.cornerRadius = 8.0;
        self.layer.masksToBounds = YES;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, frame.size.width - 24, frame.size.height)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)loadAd {
    if (![[TurboAdSDK sharedSDK] config]) {
        NSError *error = [NSError errorWithDomain:TurboAdSDKErrorDomain
                                             code:TurboAdErrorCodeAdNotReady
                                         userInfo:@{NSLocalizedDescriptionKey: @"SDK is not initialized."}];
        if ([self.delegate respondsToSelector:@selector(bannerView:didFailWithError:)]) {
            [self.delegate bannerView:self didFailWithError:error];
        }
        return;
    }

    _titleLabel.text = @"Turbo Banner Ready";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(bannerViewDidLoad:)]) {
            [self.delegate bannerViewDidLoad:self];
        }
    });
}
@end


// --- Interstitial Ad ---
@implementation TurboAdInterstitialAd {
    NSString *_placementID;
    BOOL _ready;
}

- (instancetype)initWithPlacementID:(NSString *)placementID {
    self = [super init];
    if (self) {
        _placementID = [placementID copy];
    }
    return self;
}

- (void)loadAd {
    if (![[TurboAdSDK sharedSDK] config]) {
        NSError *error = [NSError errorWithDomain:TurboAdSDKErrorDomain
                                             code:TurboAdErrorCodeAdNotReady
                                         userInfo:@{NSLocalizedDescriptionKey: @"SDK is not initialized."}];
        if ([self.delegate respondsToSelector:@selector(interstitialAd:didFailWithError:)]) {
            [self.delegate interstitialAd:self didFailWithError:error];
        }
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_ready = YES;
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidLoad:)]) {
            [self.delegate interstitialAdDidLoad:self];
        }
    });
}

- (BOOL)showFromViewController:(UIViewController *)viewController {
    if (!_ready || !viewController) {
        return NO;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TurboAd"
                                                                   message:[NSString stringWithFormat:@"Interstitial ad for %@", _placementID]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidClose:)]) {
            [self.delegate interstitialAdDidClose:self];
        }
    }]];

    [viewController presentViewController:alert animated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidShow:)]) {
            [self.delegate interstitialAdDidShow:self];
        }
    }];
    return YES;
}
@end


// --- Rewarded Video Ad ---
@implementation TurboAdRewardedVideoAd {
    NSString *_placementID;
    BOOL _ready;
}

- (instancetype)initWithPlacementID:(NSString *)placementID {
    self = [super init];
    if (self) {
        _placementID = [placementID copy];
    }
    return self;
}

- (void)loadAd {
    if (![[TurboAdSDK sharedSDK] config]) {
        NSError *error = [NSError errorWithDomain:TurboAdSDKErrorDomain
                                             code:TurboAdErrorCodeAdNotReady
                                         userInfo:@{NSLocalizedDescriptionKey: @"SDK is not initialized."}];
        if ([self.delegate respondsToSelector:@selector(rewardedVideoAd:didFailWithError:)]) {
            [self.delegate rewardedVideoAd:self didFailWithError:error];
        }
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_ready = YES;
        if ([self.delegate respondsToSelector:@selector(rewardedVideoAdDidLoad:)]) {
            [self.delegate rewardedVideoAdDidLoad:self];
        }
    });
}

- (BOOL)showFromViewController:(UIViewController *)viewController {
    if (!_ready || !viewController) {
        return NO;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TurboAd"
                                                                   message:[NSString stringWithFormat:@"Rewarded video for %@", _placementID]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Claim Reward" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.delegate respondsToSelector:@selector(rewardedVideoAdDidReward:)]) {
            [self.delegate rewardedVideoAdDidReward:self];
        }
    }]];

    [viewController presentViewController:alert animated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(rewardedVideoAdDidShow:)]) {
            [self.delegate rewardedVideoAdDidShow:self];
        }
    }];
    return YES;
}
@end


// --- Splash Ad ---
@implementation TurboAdSplashAd {
    NSString *_placementID;
    BOOL _ready;
    UIView *_splashOverlayView;
}

- (instancetype)initWithPlacementID:(NSString *)placementID {
    self = [super init];
    if (self) {
        _placementID = [placementID copy];
    }
    return self;
}

- (void)loadAd {
    if (![[TurboAdSDK sharedSDK] config]) {
        NSError *error = [NSError errorWithDomain:TurboAdSDKErrorDomain
                                             code:TurboAdErrorCodeAdNotReady
                                         userInfo:@{NSLocalizedDescriptionKey: @"SDK is not initialized."}];
        if ([self.delegate respondsToSelector:@selector(splashAd:didFailWithError:)]) {
            [self.delegate splashAd:self didFailWithError:error];
        }
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_ready = YES;
        if ([self.delegate respondsToSelector:@selector(splashAdDidLoad:)]) {
            [self.delegate splashAdDidLoad:self];
        }
    });
}

- (BOOL)showInWindow:(UIWindow *)window {
    if (!_ready || !window) {
        return NO;
    }

    _splashOverlayView = [[UIView alloc] initWithFrame:window.bounds];
    _splashOverlayView.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];

    UILabel *adLabel = [[UILabel alloc] initWithFrame:_splashOverlayView.bounds];
    adLabel.textAlignment = NSTextAlignmentCenter;
    adLabel.text = [NSString stringWithFormat:@"Splash Ad: %@", _placementID];
    adLabel.textColor = [UIColor whiteColor];
    adLabel.font = [UIFont boldSystemFontOfSize:24];
    [_splashOverlayView addSubview:adLabel];

    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeSystem];
    skipButton.frame = CGRectMake(window.bounds.size.width - 70, 50, 60, 30);
    [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    skipButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    skipButton.layer.cornerRadius = 15;
    [skipButton addTarget:self action:@selector(skipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_splashOverlayView addSubview:skipButton];

    [window addSubview:_splashOverlayView];

    if ([self.delegate respondsToSelector:@selector(splashAdDidShow:)]) {
        [self.delegate splashAdDidShow:self];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissSplash];
    });

    return YES;
}

- (void)skipButtonTapped {
    [self dismissSplash];
}

- (void)dismissSplash {
    if (_splashOverlayView) {
        [UIView animateWithDuration:0.3 animations:^{
            self->_splashOverlayView.alpha = 0;
        } completion:^(BOOL finished) {
            [self->_splashOverlayView removeFromSuperview];
            self->_splashOverlayView = nil;
            if ([self.delegate respondsToSelector:@selector(splashAdDidClose:)]) {
                [self.delegate splashAdDidClose:self];
            }
        }];
    }
}
@end


// --- Native Ad ---
@interface TurboAdNativeAd ()
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *text;
@property (nonatomic, copy, readwrite) NSString *ctaText;
@property (nonatomic, copy, readwrite) NSString *iconURL;
@property (nonatomic, strong) NSMutableArray<UIView *> *registeredViews;
@end

@implementation TurboAdNativeAd {
    NSString *_placementID;
}

- (instancetype)initWithPlacementID:(NSString *)placementID {
    self = [super init];
    if (self) {
        _placementID = [placementID copy];
        _registeredViews = [NSMutableArray array];
    }
    return self;
}

- (void)loadAd {
    if (![[TurboAdSDK sharedSDK] config]) {
        NSError *error = [NSError errorWithDomain:TurboAdSDKErrorDomain
                                             code:TurboAdErrorCodeAdNotReady
                                         userInfo:@{NSLocalizedDescriptionKey: @"SDK is not initialized."}];
        if ([self.delegate respondsToSelector:@selector(nativeAd:didFailWithError:)]) {
            [self.delegate nativeAd:self didFailWithError:error];
        }
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.title = @"Native Ad Title";
        self.text = @"This is an awesome native ad description. Learn more now!";
        self.ctaText = @"Install";
        self.iconURL = @"https://example.com/icon.png"; // Mock URL

        if ([self.delegate respondsToSelector:@selector(nativeAdDidLoad:)]) {
            [self.delegate nativeAdDidLoad:self];
        }
    });
}

- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews {
    for (UIView *view in self.registeredViews) {
        for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                [view removeGestureRecognizer:gesture];
            }
        }
    }
    [self.registeredViews removeAllObjects];

    for (UIView *view in clickableViews) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClick:)];
        [view addGestureRecognizer:tap];
        [self.registeredViews addObject:view];
        view.userInteractionEnabled = YES;
    }
}

- (void)handleClick:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    }
}
@end

@implementation TurboAdNativeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _textLabel = [[UILabel alloc] init];
        _ctaButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _iconImageView = [[UIImageView alloc] init];

        [self addSubview:_titleLabel];
        [self addSubview:_textLabel];
        [self addSubview:_ctaButton];
        [self addSubview:_iconImageView];
    }
    return self;
}

- (void)refreshWithNativeAd:(TurboAdNativeAd *)nativeAd {
    self.titleLabel.text = nativeAd.title;
    self.textLabel.text = nativeAd.text;
    [self.ctaButton setTitle:nativeAd.ctaText forState:UIControlStateNormal];
    // Normally load iconURL into iconImageView here asynchronously
    self.iconImageView.backgroundColor = [UIColor grayColor];

    // Register views for click
    [nativeAd registerClickableViews:@[self.titleLabel, self.textLabel, self.ctaButton, self.iconImageView, self]];
}

@end
