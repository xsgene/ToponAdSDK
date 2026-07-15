//
//  TurboAdRewardedVideoManager.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdManagement.h"

NS_ASSUME_NONNULL_BEGIN

/// 激励视频广告管理器
@interface TurboAdRewardedVideoManager : NSObject <TurboAdManagement>

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
