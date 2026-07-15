//
//  TurboAdNativeAd.m
//  TurboAdSDK
//

#import "TurboAdNativeAd.h"
#import "TurboAdLogger.h"
#import "TurboAdTracker.h"

@interface TurboAdNativeAd ()
@property (nonatomic, strong) NSMutableArray<UIView *> *registeredViews;
@end

@implementation TurboAdNativeAd

- (instancetype)init {
    self = [super init];
    if (self) {
        _registeredViews = [NSMutableArray array];
        _isExpired = NO;
    }
    return self;
}

- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews {
    [self unregisterClickableViews];
    
    for (UIView *view in clickableViews) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClick:)];
        [view addGestureRecognizer:tap];
        [self.registeredViews addObject:view];
    }
    
    TurboLogDebug(@"Registered %lu clickable views", (unsigned long)clickableViews.count);
}

- (void)unregisterClickableViews {
    for (UIView *view in self.registeredViews) {
        NSArray *gestures = view.gestureRecognizers;
        for (UIGestureRecognizer *gesture in gestures) {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                [view removeGestureRecognizer:gesture];
            }
        }
    }
    [self.registeredViews removeAllObjects];
}

- (void)handleClick:(UITapGestureRecognizer *)gesture {
    TurboLogInfo(@"Native ad clicked");
    
    // 打开点击链接
    if (self.clickURL) {
        NSURL *url = [NSURL URLWithString:self.clickURL];
        if (url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else if (self.deeplinkURL) {
        NSURL *url = [NSURL URLWithString:self.deeplinkURL];
        if (url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
}

@end
