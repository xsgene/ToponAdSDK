//
//  TurboAdNativeRendering.h
//  TurboAdSDK
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 原生广告渲染视图协议 - 开发者需实现此协议提供自定义 UI 组件
@protocol TurboAdNativeRendering <NSObject>

@required
/// 广告图标 ImageView
@property (nonatomic, strong, readonly) UIImageView *iconImageView;

/// 广告主标题 Label
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/// 广告描述文本 Label
@property (nonatomic, strong, readonly) UILabel *textLabel;

/// 行动号召按钮/Label
@property (nonatomic, strong, readonly) UILabel *ctaLabel;

@optional
/// 广告主名称 Label
@property (nonatomic, strong, readonly) UILabel *advertiserLabel;

/// 评分 Label
@property (nonatomic, strong, readonly) UILabel *ratingLabel;

/// 主图/媒体视图
@property (nonatomic, strong, readonly) UIView *mediaView;

/// 不喜欢按钮
@property (nonatomic, strong, readonly) UIButton *dislikeButton;

/// 广告标识视图
@property (nonatomic, strong, readonly) UIView *adChoiceView;

@end

NS_ASSUME_NONNULL_END
