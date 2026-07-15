//
//  TurboAdNativeAd.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 原生广告数据对象
@interface TurboAdNativeAd : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *ctaText;
@property (nonatomic, copy) NSString *advertiserName;
@property (nonatomic, copy, nullable) NSString *rating;
@property (nonatomic, copy, nullable) NSString *iconURL;
@property (nonatomic, copy, nullable) NSString *imageURL;
@property (nonatomic, copy, nullable) NSString *videoURL;
@property (nonatomic, copy, nullable) NSString *clickURL;
@property (nonatomic, copy, nullable) NSString *deeplinkURL;
@property (nonatomic, strong, nullable) UIImage *iconImage;
@property (nonatomic, strong, nullable) UIImage *mainImage;

/// 广告是否已过期
@property (nonatomic, assign) BOOL isExpired;

/// 注册点击区域
- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews;

/// 注销点击区域
- (void)unregisterClickableViews;

@end

NS_ASSUME_NONNULL_END
