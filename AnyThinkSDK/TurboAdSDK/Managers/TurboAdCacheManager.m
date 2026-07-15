//
//  TurboAdCacheManager.m
//  TurboAdSDK
//

#import "TurboAdCacheManager.h"
#import "TurboAdStorage.h"
#import "TurboAdLogger.h"
#import "TurboAdUtils.h"
#import "TurboAdNetworking.h"

static const NSUInteger kMaxMemoryCacheCount = 100;

@interface TurboAdCacheManager ()
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) NSCache *imageCache;
@end

@implementation TurboAdCacheManager

+ (instancetype)sharedManager {
    static TurboAdCacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.countLimit = kMaxMemoryCacheCount;
        _imageCache = [[NSCache alloc] init];
        _imageCache.countLimit = kMaxMemoryCacheCount;
        
        // 监听内存警告
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cacheImageData:(NSData *)data forKey:(NSString *)key {
    if (!data || !key) return;
    
    [self.memoryCache setObject:data forKey:key];
    
    // 同时写入磁盘
    NSString *filename = [TurboAdUtils md5String:key];
    [[TurboAdStorage sharedStorage] saveData:data toFile:filename];
    
    TurboLogVerbose(@"Cached image data for key: %@", key);
}

- (NSData *)cachedImageDataForKey:(NSString *)key {
    if (!key) return nil;
    
    // 先从内存缓存获取
    NSData *data = [self.memoryCache objectForKey:key];
    if (data) return data;
    
    // 从磁盘读取
    NSString *filename = [TurboAdUtils md5String:key];
    data = [[TurboAdStorage sharedStorage] loadDataFromFile:filename];
    if (data) {
        [self.memoryCache setObject:data forKey:key]; // 回写内存
    }
    return data;
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key {
    if (!image || !key) return;
    
    [self.imageCache setObject:image forKey:key];
    
    // 同时缓存原始数据
    NSData *data = UIImagePNGRepresentation(image);
    if (data) {
        [self cacheImageData:data forKey:key];
    }
}

- (UIImage *)cachedImageForKey:(NSString *)key {
    if (!key) return nil;
    
    // 先从内存图片缓存获取
    UIImage *image = [self.imageCache objectForKey:key];
    if (image) return image;
    
    // 从磁盘读取数据并创建图片
    NSData *data = [self cachedImageDataForKey:key];
    if (data) {
        image = [UIImage imageWithData:data];
        if (image) {
            [self.imageCache setObject:image forKey:key];
        }
    }
    return image;
}

- (BOOL)hasCacheForKey:(NSString *)key {
    if (!key) return NO;
    
    if ([self.imageCache objectForKey:key] || [self.memoryCache objectForKey:key]) {
        return YES;
    }
    
    NSString *filename = [TurboAdUtils md5String:key];
    NSString *filePath = [[TurboAdStorage sharedStorage] filePathForFilename:filename];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (void)removeCacheForKey:(NSString *)key {
    if (!key) return;
    
    [self.memoryCache removeObjectForKey:key];
    [self.imageCache removeObjectForKey:key];
    
    NSString *filename = [TurboAdUtils md5String:key];
    [[TurboAdStorage sharedStorage] removeFile:filename];
}

- (void)clearAllCache {
    [self.memoryCache removeAllObjects];
    [self.imageCache removeAllObjects];
    [[TurboAdStorage sharedStorage] clearCache];
    TurboLogInfo(@"All ad cache cleared");
}

- (unsigned long long)totalCacheSize {
    return [[TurboAdStorage sharedStorage] cacheSize];
}

- (void)handleMemoryWarning {
    [self.memoryCache removeAllObjects];
    [self.imageCache removeAllObjects];
    TurboLogWarning(@"Memory warning received, cleared memory cache");
}

- (void)downloadImageWithURL:(NSString *)URLString completion:(void(^)(UIImage *image, NSError *error))completion {
    if (!URLString) {
        if (completion) completion(nil, nil);
        return;
    }
    
    // 先检查缓存
    UIImage *cachedImage = [self cachedImageForKey:URLString];
    if (cachedImage) {
        if (completion) completion(cachedImage, nil);
        return;
    }
    
    // 从网络下载
    [[TurboAdNetworking sharedManager] downloadImageWithURL:URLString completion:^(UIImage *image, NSError *error) {
        if (image) {
            [self cacheImage:image forKey:URLString];
        }
        if (completion) completion(image, error);
    }];
}

@end
