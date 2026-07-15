//
//  TurboAdRewardedVideoDelegate.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 激励视频广告回调协议
@protocol TurboAdRewardedVideoDelegate <NSObject>
@optional

/// 激励视频开始播放
- (void)rewardedVideoDidStartPlayingForPlacementID:(NSString *)placementID;

/// 激励视频结束播放
- (void)rewardedVideoDidEndPlayingForPlacementID:(NSString *)placementID;

/// 激励视频播放失败
- (void)rewardedVideoDidFailToPlayForPlacementID:(NSString *)placementID error:(NSError *)error;

/// 激励视频关闭
- (void)rewardedVideoDidCloseForPlacementID:(NSString *)placementID rewarded:(BOOL)rewarded;

/// 激励视频被点击
- (void)rewardedVideoDidClickForPlacementID:(NSString *)placementID;

/// 激励视频奖励达成
- (void)rewardedVideoDidRewardSuccessForPlacementID:(NSString *)placementID;

/// 激励视频深度链接
- (void)rewardedVideoDidDeepLinkForPlacementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
