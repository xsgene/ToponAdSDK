#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TurboAPI : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy, readonly) NSString *appID;
@property (nonatomic, copy, readonly) NSString *appKey;

- (BOOL)startWithAppID:(NSString *)appID appKey:(NSString *)appKey error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
