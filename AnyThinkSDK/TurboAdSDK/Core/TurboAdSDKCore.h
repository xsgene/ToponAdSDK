//
//  TurboAdSDKCore.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdSDKConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// SDK 初始化完成回调
typedef void(^TurboAdSDKInitCompletion)(BOOL success, NSError * _Nullable error);

/// SDK 核心单例 - 管理 SDK 初始化和全局状态
@interface TurboAdSDKCore : NSObject

/// SDK 是否已初始化
@property (nonatomic, assign, readonly, getter=isInitialized) BOOL initialized;

/// 当前配置
@property (nonatomic, strong, readonly, nullable) TurboAdSDKConfig *config;

/// 设备唯一标识
@property (nonatomic, copy, readonly) NSString *deviceID;

+ (instancetype)sharedCore;

/// 初始化 SDK
- (void)initializeWithConfig:(TurboAdSDKConfig *)config completion:(nullable TurboAdSDKInitCompletion)completion;

/// 获取 SDK 版本
- (NSString *)sdkVersion;

/// 检查是否已初始化，未初始化则记录错误
- (BOOL)checkInitialized;

@end

NS_ASSUME_NONNULL_END
