//
//  TurboAdInterstitialManager.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdManagement.h"

NS_ASSUME_NONNULL_BEGIN

/// 插屏广告管理器
@interface TurboAdInterstitialManager : NSObject <TurboAdManagement>

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
