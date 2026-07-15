//
//  TurboAdCacheManager.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 广告缓存管理器 - 管理图片等资源的本地缓存
@interface TurboAdCacheManager : NSObject

+ (instancetype)sharedManager;

/// 缓存图片数据
- (void)cacheImageData:(NSData *)data forKey:(NSString *)key;

/// 获取缓存的图片数据
- (nullable NSData *)cachedImageDataForKey:(NSString *)key;

/// 缓存图片
- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;

/// 获取缓存的图片
- (nullable UIImage *)cachedImageForKey:(NSString *)key;

/// 检查是否有缓存
- (BOOL)hasCacheForKey:(NSString *)key;

/// 移除指定缓存
- (void)removeCacheForKey:(NSString *)key;

/// 清除所有缓存
- (void)clearAllCache;

/// 获取缓存大小（字节）
- (unsigned long long)totalCacheSize;

/// 下载并缓存图片
- (void)downloadImageWithURL:(NSString *)URLString completion:(void(^)(UIImage * _Nullable image, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
