//
//  TurboAdSDKConfig.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import "TurboAdLogger.h"

NS_ASSUME_NONNULL_BEGIN

/// SDK 配置
@interface TurboAdSDKConfig : NSObject

/// App ID（必填）
@property (nonatomic, copy) NSString *appID;

/// App Key（必填）
@property (nonatomic, copy) NSString *appKey;

/// 日志级别，默认 TurboAdLogLevelWarning
@property (nonatomic, assign) TurboAdLogLevel logLevel;

/// 是否测试模式
@property (nonatomic, assign, getter=isTestMode) BOOL testMode;

/// 用户 ID（可选，用于服务端验证）
@property (nonatomic, copy, nullable) NSString *userID;

/// 服务器 URL（可选，自定义服务器地址）
@property (nonatomic, copy, nullable) NSString *serverURL;

/// 创建配置
+ (instancetype)configWithAppID:(NSString *)appID appKey:(NSString *)appKey;

@end

NS_ASSUME_NONNULL_END
