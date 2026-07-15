//
//  TurboAdConstants.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SDK Version
extern NSString * const kTurboAdSDKVersion;

#pragma mark - Error Domain
extern NSString * const kTurboAdErrorDomain;

#pragma mark - Error Codes
typedef NS_ENUM(NSInteger, TurboAdErrorCode) {
    TurboAdErrorCodeUnknown = 0,
    TurboAdErrorCodeInvalidConfiguration = 1001,
    TurboAdErrorCodeSDKNotInitialized = 1002,
    TurboAdErrorCodeAdNotReady = 2001,
    TurboAdErrorCodeAdExpired = 2002,
    TurboAdErrorCodeAdAlreadyShown = 2003,
    TurboAdErrorCodeNetworkError = 3001,
    TurboAdErrorCodeServerError = 3002,
    TurboAdErrorCodeParseError = 3003,
    TurboAdErrorCodeTimeout = 3004,
    TurboAdErrorCodeNoAd = 4001,
    TurboAdErrorCodeFrequencyLimited = 5001,
    TurboAdErrorCodePlacementNotFound = 5002,
};

#pragma mark - Ad Format
typedef NS_ENUM(NSInteger, TurboAdFormat) {
    TurboAdFormatRewardedVideo = 1,
    TurboAdFormatInterstitial = 2,
    TurboAdFormatBanner = 3,
    TurboAdFormatSplash = 4,
    TurboAdFormatNative = 5,
};

#pragma mark - Show Type
typedef NS_ENUM(NSInteger, TurboAdShowType) {
    TurboAdShowTypePriority = 0,
    TurboAdShowTypeSerial = 1,
};

#pragma mark - Ad Loading Extra Keys
extern NSString * const kTurboAdExtraUserIDKey;
extern NSString * const kTurboAdExtraSceneKey;
extern NSString * const kTurboAdExtraCustomDataKey;

#pragma mark - Notifications
extern NSString * const kTurboAdNotificationSDKDidInitialize;
extern NSString * const kTurboAdNotificationAdDidLoad;
extern NSString * const kTurboAdNotificationAdDidShow;
extern NSString * const kTurboAdNotificationAdDidClick;
extern NSString * const kTurboAdNotificationAdDidClose;

#pragma mark - Storage Keys
extern NSString * const kTurboAdStorageKeyAppID;
extern NSString * const kTurboAdStorageKeyDeviceID;
extern NSString * const kTurboAdStorageKeyFirstLaunchTime;

NS_ASSUME_NONNULL_END
