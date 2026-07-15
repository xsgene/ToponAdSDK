//
//  TurboAdNativeManager.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdManagement.h"

NS_ASSUME_NONNULL_BEGIN

/// 原生广告管理器
@interface TurboAdNativeManager : NSObject <TurboAdManagement>

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
