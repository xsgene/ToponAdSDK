//
//  TurboAdBannerManager.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdManagement.h"

NS_ASSUME_NONNULL_BEGIN

/// 横幅广告管理器
@interface TurboAdBannerManager : NSObject <TurboAdManagement>

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
