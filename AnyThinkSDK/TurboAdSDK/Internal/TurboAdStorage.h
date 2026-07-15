//
//  TurboAdStorage.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TurboAdStorage : NSObject

+ (instancetype)sharedStorage;

#pragma mark - NSUserDefaults
- (void)setObject:(nullable id)object forKey:(NSString *)key;
- (nullable id)objectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;

#pragma mark - File Storage
- (BOOL)saveData:(NSData *)data toFile:(NSString *)filename;
- (nullable NSData *)loadDataFromFile:(NSString *)filename;
- (BOOL)removeFile:(NSString *)filename;
- (nullable NSString *)filePathForFilename:(NSString *)filename;

#pragma mark - Cache Directory
- (NSString *)cacheDirectoryPath;
- (BOOL)clearCache;
- (unsigned long long)cacheSize;

@end

NS_ASSUME_NONNULL_END
