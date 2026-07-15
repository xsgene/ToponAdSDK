//
//  TurboAdNativeView.m
//  TurboAdSDK
//

#import "TurboAdNativeView.h"
#import "TurboAdNativeAd.h"
#import "TurboAdManager.h"
#import "TurboAdNativeManager.h"
#import "TurboAdObject.h"
#import "TurboAdConstants.h"
#import "TurboAdLogger.h"
#import "TurboAdUtils.h"
#import "TurboAdCacheManager.h"

@interface TurboAdNativeView () <TurboAdLoadingDelegate>
@property (nonatomic, copy, readwrite) NSString *placementID;
@property (nonatomic, strong, readwrite, nullable) TurboAdNativeAd *nativeAd;
@property (nonatomic, strong, nullable) UIView<TurboAdNativeRendering> *renderingView;
@end

@implementation TurboAdNativeView

- (instancetype)initWithFrame:(CGRect)frame placementID:(NSString *)placementID {
    self = [super initWithFrame:frame];
    if (self) {
        _placementID = [placementID copy];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)loadAd {
    [[TurboAdManager sharedManager] loadADWithPlacementID:self.placementID
                                                   extra:nil
                                                delegate:self];
}

- (void)renderWithNativeAd:(TurboAdNativeAd *)nativeAd
         renderingViewClass:(Class<TurboAdNativeRendering>)renderingViewClass {
    self.nativeAd = nativeAd;
    
    if (!renderingViewClass) {
        TurboLogError(@"Rendering view class is nil");
        return;
    }
    
    // 创建渲染视图
    self.renderingView = [[renderingViewClass alloc] initWithFrame:self.bounds];
    if ([self.renderingView respondsToSelector:@selector(setAutoresizingMask:)]) {
        self.renderingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    [self addSubview:self.renderingView];
    
    // 填充数据
    [self fillRenderingViewWithNativeAd:nativeAd];
    
    // 通知展示
    if ([self.delegate respondsToSelector:@selector(nativeAdDidShowForPlacementID:)]) {
        [self.delegate nativeAdDidShowForPlacementID:self.placementID];
    }
}

- (void)fillRenderingViewWithNativeAd:(TurboAdNativeAd *)nativeAd {
    if (!self.renderingView) return;
    
    // 填充标题
    if (self.renderingView.titleLabel) {
        self.renderingView.titleLabel.text = nativeAd.title;
    }
    
    // 填充描述
    if (self.renderingView.textLabel) {
        self.renderingView.textLabel.text = nativeAd.text;
    }
    
    // 填充 CTA
    if (self.renderingView.ctaLabel) {
        self.renderingView.ctaLabel.text = nativeAd.ctaText;
    }
    
    // 填充广告主名称
    if ([self.renderingView respondsToSelector:@selector(advertiserLabel)] && self.renderingView.advertiserLabel) {
        self.renderingView.advertiserLabel.text = nativeAd.advertiserName;
    }
    
    // 填充评分
    if ([self.renderingView respondsToSelector:@selector(ratingLabel)] && self.renderingView.ratingLabel) {
        self.renderingView.ratingLabel.text = nativeAd.rating;
    }
    
    // 加载图标
    if (nativeAd.iconURL) {
        [[TurboAdCacheManager sharedManager] downloadImageWithURL:nativeAd.iconURL completion:^(UIImage *image, NSError *error) {
            if (image && self.renderingView.iconImageView) {
                [TurboAdUtils runOnMainThread:^{
                    self.renderingView.iconImageView.image = image;
                }];
            }
        }];
    } else if (nativeAd.iconImage && self.renderingView.iconImageView) {
        self.renderingView.iconImageView.image = nativeAd.iconImage;
    }
    
    // 加载主图
    if ([self.renderingView respondsToSelector:@selector(mediaView)] && nativeAd.imageURL) {
        [[TurboAdCacheManager sharedManager] downloadImageWithURL:nativeAd.imageURL completion:^(UIImage *image, NSError *error) {
            if (image) {
                [TurboAdUtils runOnMainThread:^{
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.renderingView.mediaView.bounds];
                    imageView.image = image;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.clipsToBounds = YES;
                    [self.renderingView.mediaView addSubview:imageView];
                }];
            }
        }];
    }
}

- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews {
    [self.nativeAd registerClickableViews:clickableViews];
}

#pragma mark - TurboAdLoadingDelegate

- (void)didFinishLoadingAdWithPlacementID:(NSString *)placementID {
    TurboLogDebug(@"Native ad loaded: %@", placementID);
    
    // 创建原生广告数据对象
    TurboAdNativeAd *nativeAd = [[TurboAdNativeAd alloc] init];
    nativeAd.title = @"Sample Ad Title";
    nativeAd.text = @"This is a sample native ad description.";
    nativeAd.ctaText = @"Learn More";
    nativeAd.advertiserName = @"Sample Advertiser";
    self.nativeAd = nativeAd;
    
    [TurboAdUtils runOnMainThread:^{
        if ([self.delegate respondsToSelector:@selector(nativeAdDidLoadForPlacementID:)]) {
            [self.delegate nativeAdDidLoadForPlacementID:placementID];
        }
    }];
}

- (void)didFailToLoadAdWithPlacementID:(NSString *)placementID error:(NSError *)error {
    TurboLogDebug(@"Native ad load failed: %@, error: %@", placementID, error.localizedDescription);
    
    [TurboAdUtils runOnMainThread:^{
        if ([self.delegate respondsToSelector:@selector(nativeAdDidFailToLoadForPlacementID:error:)]) {
            [self.delegate nativeAdDidFailToLoadForPlacementID:placementID error:error];
        }
    }];
}

@end
