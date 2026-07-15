//
//  TurboAdNetworking.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TurboAdNetworkCompletion)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface TurboAdNetworking : NSObject

@property (nonatomic, strong, readonly) NSURLSession *session;

+ (instancetype)sharedManager;

- (void)GET:(NSString *)URLString
 parameters:(nullable NSDictionary *)parameters
    headers:(nullable NSDictionary<NSString *, NSString *> *)headers
 completion:(TurboAdNetworkCompletion)completion;

- (void)POST:(NSString *)URLString
  parameters:(nullable NSDictionary *)parameters
     headers:(nullable NSDictionary<NSString *, NSString *> *)headers
    bodyData:(nullable NSData *)bodyData
  completion:(TurboAdNetworkCompletion)completion;

- (void)downloadImageWithURL:(NSString *)URLString
                  completion:(void(^)(UIImage * _Nullable image, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
