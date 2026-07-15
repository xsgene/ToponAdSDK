//
//  TurboAdSDK.m
//  TurboAdSDK
//
//  TurboAdSDK - 独立广告 SDK
//  Copyright (c) 2024 TurboAdSDK. All rights reserved.
//

#import "TurboAdSDK.h"

double TurboAdSDKVersionNumber = 1.0.0;
const unsigned char TurboAdSDKVersionString[] = "1.0.0";
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

    _titleLabel.text = @"Turbo banner ready";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(bannerViewDidLoad:)]) {
            [self.delegate bannerViewDidLoad:self];
        }
    });
}
@end

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
        _ready = YES;
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
        _ready = YES;
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
