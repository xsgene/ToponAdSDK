//
//  TurboAdStorage.m
//  TurboAdSDK
//

#import "TurboAdStorage.h"
#import "TurboAdLogger.h"

@implementation TurboAdStorage

+ (instancetype)sharedStorage {
    static TurboAdStorage *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - NSUserDefaults

- (void)setObject:(id)object forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)objectForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)boolForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)integerForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

#pragma mark - File Storage

- (BOOL)saveData:(NSData *)data toFile:(NSString *)filename {
    NSString *filePath = [self filePathForFilename:filename];
    if (!filePath) return NO;
    
    BOOL success = [data writeToFile:filePath atomically:YES];
    if (success) {
        TurboLogDebug(@"Data saved to file: %@", filename);
    } else {
        TurboLogError(@"Failed to save data to file: %@", filename);
    }
    return success;
}

- (NSData *)loadDataFromFile:(NSString *)filename {
    NSString *filePath = [self filePathForFilename:filename];
    if (!filePath) return nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        TurboLogDebug(@"Data loaded from file: %@", filename);
    } else {
        TurboLogError(@"Failed to load data from file: %@", filename);
    }
    return data;
}

- (BOOL)removeFile:(NSString *)filename {
    NSString *filePath = [self filePathForFilename:filename];
    if (!filePath) return NO;
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (!success) {
        TurboLogError(@"Failed to remove file: %@, error: %@", filename, error.localizedDescription);
    }
    return success;
}

- (NSString *)filePathForFilename:(NSString *)filename {
    NSString *cacheDir = [self cacheDirectoryPath];
    if (!cacheDir) return nil;
    return [cacheDir stringByAppendingPathComponent:filename];
}

#pragma mark - Cache Directory

- (NSString *)cacheDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (paths.count == 0) return nil;
    
    NSString *cacheDir = [paths.firstObject stringByAppendingPathComponent:@"TurboAdSDK"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheDir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            TurboLogError(@"Failed to create cache directory: %@", error.localizedDescription);
            return nil;
        }
    }
    return cacheDir;
}

- (BOOL)clearCache {
    NSString *cacheDir = [self cacheDirectoryPath];
    if (!cacheDir) return NO;
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:cacheDir error:&error];
    if (error) {
        TurboLogError(@"Failed to clear cache: %@", error.localizedDescription);
        return NO;
    }
    
    // Recreate directory
    [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
    TurboLogInfo(@"Cache cleared successfully");
    return YES;
}

- (unsigned long long)cacheSize {
    NSString *cacheDir = [self cacheDirectoryPath];
    if (!cacheDir) return 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheDir]) return 0;
    
    unsigned long long totalSize = 0;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:cacheDir error:nil];
    for (NSString *filename in contents) {
        NSString *filePath = [cacheDir stringByAppendingPathComponent:filename];
        NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
        totalSize += [attrs fileSize];
    }
    return totalSize;
}

@end
