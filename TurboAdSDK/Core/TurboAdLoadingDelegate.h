#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TurboAdLoadingDelegate <NSObject>

- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID;
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
