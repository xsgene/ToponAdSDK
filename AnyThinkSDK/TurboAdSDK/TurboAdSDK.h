//
//  TurboAdSDK.h
//  TurboAdSDK
//
//  TurboAdSDK - 独立广告 SDK
//  Copyright (c) 2024 TurboAdSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! Project version number for TurboAdSDK.
FOUNDATION_EXPORT double TurboAdSDKVersionNumber;

//! Project version string for TurboAdSDK.
FOUNDATION_EXPORT const unsigned char TurboAdSDKVersionString[];

#pragma mark - Core
#import "TurboAdConstants.h"
#import "TurboAdSDKConfig.h"
#import "TurboAdSDKCore.h"
#import "TurboAdManager.h"

#pragma mark - Protocols
#import "TurboAdDelegate.h"
#import "TurboAdAdapterProtocol.h"
#import "TurboAdManagement.h"

#pragma mark - Models
#import "TurboAdPlacementModel.h"
#import "TurboAdUnitModel.h"
#import "TurboAdObject.h"
#import "TurboAdBidInfo.h"

#pragma mark - Managers
#import "TurboAdPlacementManager.h"
#import "TurboAdCapsManager.h"
#import "TurboAdTracker.h"
#import "TurboAdCacheManager.h"

#pragma mark - Rewarded Video
#import "TurboAdRewardedVideoAd.h"
#import "TurboAdRewardedVideoDelegate.h"
#import "TurboAdRewardedVideoManager.h"

#pragma mark - Interstitial
#import "TurboAdInterstitialAd.h"
#import "TurboAdInterstitialDelegate.h"
#import "TurboAdInterstitialManager.h"

#pragma mark - Banner
#import "TurboAdBannerView.h"
#import "TurboAdBannerDelegate.h"
#import "TurboAdBannerManager.h"

#pragma mark - Splash
#import "TurboAdSplashAd.h"
#import "TurboAdSplashDelegate.h"
#import "TurboAdSplashManager.h"

#pragma mark - Native
#import "TurboAdNativeAd.h"
#import "TurboAdNativeView.h"
#import "TurboAdNativeDelegate.h"
#import "TurboAdNativeRenderer.h"
#import "TurboAdNativeRendering.h"
#import "TurboAdNativeManager.h"

#pragma mark - Internal
#import "TurboAdLogger.h"
#import "TurboAdNetworking.h"
#import "TurboAdStorage.h"
#import "TurboAdThreadSafe.h"
#import "TurboAdUtils.h"
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

@protocol TurboAdSDKDelegate <NSObject>
@optional
- (void)turboAdSDKDidInitialize:(TurboAdSDK *)sdk success:(BOOL)success error:(nullable NSError *)error;
@end

@protocol TurboAdBannerViewDelegate <NSObject>
@optional
- (void)bannerViewDidLoad:(TurboAdBannerView *)bannerView;
- (void)bannerView:(TurboAdBannerView *)bannerView didFailWithError:(NSError *)error;
@end

@protocol TurboAdInterstitialAdDelegate <NSObject>
@optional
- (void)interstitialAdDidLoad:(TurboAdInterstitialAd *)ad;
- (void)interstitialAd:(TurboAdInterstitialAd *)ad didFailWithError:(NSError *)error;
- (void)interstitialAdDidShow:(TurboAdInterstitialAd *)ad;
- (void)interstitialAdDidClose:(TurboAdInterstitialAd *)ad;
@end

@protocol TurboAdRewardedVideoAdDelegate <NSObject>
@optional
- (void)rewardedVideoAdDidLoad:(TurboAdRewardedVideoAd *)ad;
- (void)rewardedVideoAd:(TurboAdRewardedVideoAd *)ad didFailWithError:(NSError *)error;
- (void)rewardedVideoAdDidShow:(TurboAdRewardedVideoAd *)ad;
- (void)rewardedVideoAdDidReward:(TurboAdRewardedVideoAd *)ad;
@end

@interface TurboAdSDKConfig : NSObject
@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, assign, getter=isTestMode) BOOL testMode;

+ (instancetype)configWithAppID:(NSString *)appID placementID:(NSString *)placementID;
@end

@interface TurboAdSDK : NSObject
+ (instancetype)sharedSDK;
- (void)initializeWithConfig:(TurboAdSDKConfig *)config completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

@property (nonatomic, strong, readonly) TurboAdSDKConfig * _Nullable config;
@property (nonatomic, assign, nullable) id<TurboAdSDKDelegate> delegate;
@end

@interface TurboAdBannerView : UIView
- (instancetype)initWithFrame:(CGRect)frame placementID:(NSString *)placementID;
@property (nonatomic, assign, nullable) id<TurboAdBannerViewDelegate> delegate;
- (void)loadAd;
@end

@interface TurboAdInterstitialAd : NSObject
- (instancetype)initWithPlacementID:(NSString *)placementID;
@property (nonatomic, assign, nullable) id<TurboAdInterstitialAdDelegate> delegate;
- (void)loadAd;
- (BOOL)showFromViewController:(UIViewController *)viewController;
@end

@interface TurboAdRewardedVideoAd : NSObject
- (instancetype)initWithPlacementID:(NSString *)placementID;
@property (nonatomic, assign, nullable) id<TurboAdRewardedVideoAdDelegate> delegate;
- (void)loadAd;
- (BOOL)showFromViewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
