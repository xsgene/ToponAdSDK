#import <Foundation/Foundation.h>
#import "TurboAdLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TurboAdManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) NSDictionary *extra;

- (void)loadADWithPlacementID:(NSString *)placementID extra:(nullable NSDictionary *)extra delegate:(id<TurboAdLoadingDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
