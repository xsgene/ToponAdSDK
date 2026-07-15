//
//  TurboAdSDK.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TurboAdErrorCode) {
    TurboAdErrorCodeUnknown = 0,
    TurboAdErrorCodeInvalidConfiguration,
    TurboAdErrorCodeAdNotReady,
    TurboAdErrorCodeRequestFailed
};

@class TurboAdSDK;
@class TurboAdBannerView;
@class TurboAdInterstitialAd;
@class TurboAdRewardedVideoAd;
@class TurboAdSplashAd;
@class TurboAdNativeAd;
@class TurboAdNativeView;

// --- Config and Core SDK ---
@interface TurboAdSDKConfig : NSObject
@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, assign, getter=isTestMode) BOOL testMode;

+ (instancetype)configWithAppID:(NSString *)appID placementID:(NSString *)placementID;
@end

@protocol TurboAdSDKDelegate <NSObject>
@optional
- (void)turboAdSDKDidInitialize:(TurboAdSDK *)sdk success:(BOOL)success error:(nullable NSError *)error;
@end

@interface TurboAdSDK : NSObject
+ (instancetype)sharedSDK;
- (void)initializeWithConfig:(TurboAdSDKConfig *)config completion:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completion;

@property (nonatomic, strong, readonly) TurboAdSDKConfig * _Nullable config;
@property (nonatomic, weak, nullable) id<TurboAdSDKDelegate> delegate;
@end


// --- Banner Ad ---
@protocol TurboAdBannerViewDelegate <NSObject>
@optional
- (void)bannerViewDidLoad:(TurboAdBannerView *)bannerView;
- (void)bannerView:(TurboAdBannerView *)bannerView didFailWithError:(NSError *)error;
@end

@interface TurboAdBannerView : UIView
- (instancetype)initWithFrame:(CGRect)frame placementID:(NSString *)placementID;
@property (nonatomic, weak, nullable) id<TurboAdBannerViewDelegate> delegate;
- (void)loadAd;
@end


// --- Interstitial Ad ---
@protocol TurboAdInterstitialAdDelegate <NSObject>
@optional
- (void)interstitialAdDidLoad:(TurboAdInterstitialAd *)ad;
- (void)interstitialAd:(TurboAdInterstitialAd *)ad didFailWithError:(NSError *)error;
- (void)interstitialAdDidShow:(TurboAdInterstitialAd *)ad;
- (void)interstitialAdDidClose:(TurboAdInterstitialAd *)ad;
@end

@interface TurboAdInterstitialAd : NSObject
- (instancetype)initWithPlacementID:(NSString *)placementID;
@property (nonatomic, weak, nullable) id<TurboAdInterstitialAdDelegate> delegate;
- (void)loadAd;
- (BOOL)showFromViewController:(UIViewController *)viewController;
@end


// --- Rewarded Video Ad ---
@protocol TurboAdRewardedVideoAdDelegate <NSObject>
@optional
- (void)rewardedVideoAdDidLoad:(TurboAdRewardedVideoAd *)ad;
- (void)rewardedVideoAd:(TurboAdRewardedVideoAd *)ad didFailWithError:(NSError *)error;
- (void)rewardedVideoAdDidShow:(TurboAdRewardedVideoAd *)ad;
- (void)rewardedVideoAdDidReward:(TurboAdRewardedVideoAd *)ad;
@end

@interface TurboAdRewardedVideoAd : NSObject
- (instancetype)initWithPlacementID:(NSString *)placementID;
@property (nonatomic, weak, nullable) id<TurboAdRewardedVideoAdDelegate> delegate;
- (void)loadAd;
- (BOOL)showFromViewController:(UIViewController *)viewController;
@end


// --- Splash Ad ---
@protocol TurboAdSplashDelegate <NSObject>
@optional
- (void)splashAdDidLoad:(TurboAdSplashAd *)ad;
- (void)splashAd:(TurboAdSplashAd *)ad didFailWithError:(NSError *)error;
- (void)splashAdDidShow:(TurboAdSplashAd *)ad;
- (void)splashAdDidClose:(TurboAdSplashAd *)ad;
@end

@interface TurboAdSplashAd : NSObject
- (instancetype)initWithPlacementID:(NSString *)placementID;
@property (nonatomic, weak, nullable) id<TurboAdSplashDelegate> delegate;
- (void)loadAd;
- (BOOL)showInWindow:(UIWindow *)window;
@end


// --- Native Ad ---
@protocol TurboAdNativeDelegate <NSObject>
@optional
- (void)nativeAdDidLoad:(TurboAdNativeAd *)ad;
- (void)nativeAd:(TurboAdNativeAd *)ad didFailWithError:(NSError *)error;
- (void)nativeAdDidClick:(TurboAdNativeAd *)ad;
@end

@interface TurboAdNativeAd : NSObject
- (instancetype)initWithPlacementID:(NSString *)placementID;
@property (nonatomic, weak, nullable) id<TurboAdNativeDelegate> delegate;

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *ctaText;
@property (nonatomic, copy, readonly) NSString *iconURL;

- (void)loadAd;
- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews;
@end

@interface TurboAdNativeView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UIImageView *iconImageView;
- (void)refreshWithNativeAd:(TurboAdNativeAd *)nativeAd;
@end

NS_ASSUME_NONNULL_END
