//
//  TurboAdDelegate.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TurboAdObject;

/// 通用广告加载回调协议
@protocol TurboAdLoadingDelegate <NSObject>
@optional
- (void)didFinishLoadingAdWithPlacementID:(NSString *)placementID;
- (void)didFailToLoadAdWithPlacementID:(NSString *)placementID error:(NSError *)error;
@end

/// 通用广告展示回调协议
@protocol TurboAdShowingDelegate <NSObject>
@optional
- (void)didShowAdWithPlacementID:(NSString *)placementID;
- (void)didFailToShowAdWithPlacementID:(NSString *)placementID error:(NSError *)error;
- (void)didClickAdWithPlacementID:(NSString *)placementID;
- (void)didCloseAdWithPlacementID:(NSString *)placementID;
- (void)didDeepLinkWithPlacementID:(NSString *)placementID;
@end

NS_ASSUME_NONNULL_END
