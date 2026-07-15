#import "TurboNativeAdView.h"

@implementation TurboNativeAdView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _bodyLabel = [[UILabel alloc] init];
        _iconImageView = [[UIImageView alloc] init];
        _mainImageView = [[UIImageView alloc] init];
        _callToActionButton = [UIButton buttonWithType:UIButtonTypeSystem];

        [self addSubview:_titleLabel];
        [self addSubview:_bodyLabel];
        [self addSubview:_iconImageView];
        [self addSubview:_mainImageView];
        [self addSubview:_callToActionButton];

        // Setup simple layout or auto-layout here
    }
    return self;
}

@end
