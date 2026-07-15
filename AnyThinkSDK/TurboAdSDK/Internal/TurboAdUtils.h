//
//  TurboAdUtils.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TurboAdUtils : NSObject

/// 生成 UUID
+ (NSString *)generateUUID;

/// MD5 哈希
+ (NSString *)md5String:(NSString *)string;

/// 获取设备型号
+ (NSString *)deviceModel;

/// 获取系统版本
+ (NSString *)systemVersion;

/// 获取 App 版本号
+ (NSString *)appVersion;

/// 获取 App 构建号
+ (NSString *)appBuildVersion;

/// 获取屏幕宽度
+ (CGFloat)screenWidth;

/// 获取屏幕高度
+ (CGFloat)screenHeight;

/// 获取状态栏高度
+ (CGFloat)statusBarHeight;

/// 获取安全区域底部高度
+ (CGFloat)bottomSafeAreaHeight;

/// 判断是否为刘海屏
+ (BOOL)isNotchScreen;

/// JSON 字符串转字典
+ (nullable NSDictionary *)dictionaryFromJSONString:(NSString *)jsonString;

/// 字典转 JSON 字符串
+ (nullable NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary;

/// 获取当前时间戳（毫秒）
+ (NSTimeInterval)currentTimeMillis;

/// 判断字符串是否为空
+ (BOOL)isEmptyString:(NSString *)string;

/// 主线程安全执行
+ (void)runOnMainThread:(dispatch_block_t)block;

/// 延迟执行
+ (void)runAfterDelay:(NSTimeInterval)delay block:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
