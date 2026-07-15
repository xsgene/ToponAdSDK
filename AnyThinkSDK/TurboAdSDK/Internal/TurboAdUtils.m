//
//  TurboAdUtils.m
//  TurboAdSDK
//

#import "TurboAdUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>

@implementation TurboAdUtils

+ (NSString *)generateUUID {
    return [[NSUUID UUID] UUIDString];
}

+ (NSString *)md5String:(NSString *)string {
    if (!string) return nil;
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+ (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)appVersion {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return info[@"CFBundleShortVersionString"] ?: @"";
}

+ (NSString *)appBuildVersion {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return info[@"CFBundleVersion"] ?: @"";
}

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)statusBarHeight {
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                windowScene = scene;
                break;
            }
        }
        if (windowScene) {
            return windowScene.statusBarManager.statusBarFrame.size.height;
        }
    }
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (CGFloat)bottomSafeAreaHeight {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.bottom;
    }
    return 0;
}

+ (BOOL)isNotchScreen {
    return [self bottomSafeAreaHeight] > 0;
}

+ (NSDictionary *)dictionaryFromJSONString:(NSString *)jsonString {
    if (!jsonString) return nil;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) return nil;
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        return nil;
    }
    return dict;
}

+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary {
    if (!dictionary) return nil;
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error) return nil;
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSTimeInterval)currentTimeMillis {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

+ (BOOL)isEmptyString:(NSString *)string {
    if (!string) return YES;
    if (![string isKindOfClass:[NSString class]]) return YES;
    if (string.length == 0) return YES;
    
    NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmed.length == 0;
}

+ (void)runOnMainThread:(dispatch_block_t)block {
    if (!block) return;
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (void)runAfterDelay:(NSTimeInterval)delay block:(dispatch_block_t)block {
    if (!block) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

@end
