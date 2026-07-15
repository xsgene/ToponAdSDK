# TurboAdSDK

TurboAdSDK is a lightweight Objective-C ad SDK skeleton that demonstrates a simple architecture for:

- SDK initialization
- Banner ad loading
- Interstitial ad presentation
- Rewarded video presentation

## Usage example

```objc
#import "TurboAdSDK.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        TurboAdSDKConfig *config = [TurboAdSDKConfig configWithAppID:@"your-app-id" placementID:@"your-placement-id"];
        [[TurboAdSDK sharedSDK] initializeWithConfig:config completion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"TurboAdSDK initialized");
            }
        }];

        TurboAdBannerView *banner = [[TurboAdBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50) placementID:@"banner-placement"];
        [banner loadAd];
    }
}
```

## Structure

- TurboAdSDK.h: public interface
- TurboAdSDK.m: implementation of SDK logic and ad classes
