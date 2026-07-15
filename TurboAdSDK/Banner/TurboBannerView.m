#import "TurboBannerView.h"

@implementation TurboBannerView

- (void)loadBannerAd {
    // Simulate loading internal banner UI
    self.backgroundColor = [UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.text = @"Turbo Banner Ad";
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:label];
}

@end
