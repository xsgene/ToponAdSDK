#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TurboAdLoader : NSObject

+ (instancetype)sharedLoader;

- (void)requestAdWithPlacementID:(NSString *)placementID
                           extra:(nullable NSDictionary *)extra
                      completion:(void(^)(NSDictionary * _Nullable offerDict, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
