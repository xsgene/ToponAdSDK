//
//  TurboAdLoader.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TurboAdPlacementModel;
@class TurboAdObject;

/// 广告加载引擎 - 负责 Waterfall 调度
@interface TurboAdLoader : NSObject

/// 加载广告（Waterfall 模式）
- (void)loadAdWithPlacementModel:(TurboAdPlacementModel *)placementModel
                           extra:(nullable NSDictionary *)extra
                      completion:(void(^)(BOOL success, TurboAdObject * _Nullable adObject, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
