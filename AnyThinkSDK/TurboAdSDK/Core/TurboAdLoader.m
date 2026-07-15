//
//  TurboAdLoader.m
//  TurboAdSDK
//

#import "TurboAdLoader.h"
#import "TurboAdPlacementModel.h"
#import "TurboAdUnitModel.h"
#import "TurboAdObject.h"
#import "TurboAdAdapterProtocol.h"
#import "TurboAdConstants.h"
#import "TurboAdLogger.h"
#import "TurboAdUtils.h"

@interface TurboAdLoader ()
@property (nonatomic, strong, nullable) TurboAdPlacementModel *currentPlacementModel;
@property (nonatomic, strong, nullable) NSDictionary *currentExtra;
@property (nonatomic, copy, nullable) void(^loadCompletion)(BOOL success, TurboAdObject * _Nullable adObject, NSError * _Nullable error);
@property (nonatomic, strong) NSMutableArray<TurboAdUnitModel *> *pendingUnits;
@property (nonatomic, strong, nullable) TurboAdObject *loadedAd;
@property (nonatomic, strong, nullable) NSTimer *timeoutTimer;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, assign) NSInteger maxConcurrent;
@property (nonatomic, assign) NSInteger currentLoadingCount;
@end

@implementation TurboAdLoader

- (instancetype)init {
    self = [super init];
    if (self) {
        _pendingUnits = [NSMutableArray array];
        _isCompleted = NO;
        _maxConcurrent = 3;
        _currentLoadingCount = 0;
    }
    return self;
}

- (void)loadAdWithPlacementModel:(TurboAdPlacementModel *)placementModel
                           extra:(NSDictionary *)extra
                      completion:(void(^)(BOOL success, TurboAdObject *adObject, NSError *error))completion {
    
    self.currentPlacementModel = placementModel;
    self.currentExtra = extra;
    self.loadCompletion = completion;
    self.isCompleted = NO;
    self.loadedAd = nil;
    self.currentLoadingCount = 0;
    self.maxConcurrent = placementModel.maxConcurrentRequestCount > 0 ? placementModel.maxConcurrentRequestCount : 3;
    
    // 获取所有 unit groups 并按 ecpm 排序
    NSArray<TurboAdUnitModel *> *allUnits = [placementModel allUnitGroups];
    NSArray *sortedUnits = [allUnits sortedArrayUsingComparator:^NSComparisonResult(TurboAdUnitModel *a, TurboAdUnitModel *b) {
        return b.ecpmLevel > a.ecpmLevel ? NSOrderedDescending : (b.ecpmLevel < a.ecpmLevel ? NSOrderedAscending : NSOrderedSame);
    }];
    
    [self.pendingUnits setArray:[sortedUnits mutableCopy]];
    
    TurboLogDebug(@"Starting waterfall load for placement: %@, %lu units", placementModel.placementID, (unsigned long)self.pendingUnits.count);
    
    if (self.pendingUnits.count == 0) {
        [self completeWithFailure:[self noAdError]];
        return;
    }
    
    // 设置总超时
    NSTimeInterval totalTimeout = [self totalTimeoutForUnits:sortedUnits];
    [self startTimeoutTimer:totalTimeout];
    
    // 开始加载
    [self loadNextUnit];
}

#pragma mark - Waterfall Loading

- (void)loadNextUnit {
    if (self.isCompleted) return;
    
    if (self.pendingUnits.count == 0 && self.currentLoadingCount == 0) {
        // 所有 unit 都已处理完毕
        [self stopTimeoutTimer];
        if (self.loadedAd) {
            [self completeWithSuccess:self.loadedAd];
        } else {
            [self completeWithFailure:[self noAdError]];
        }
        return;
    }
    
    // 检查并发限制
    while (self.currentLoadingCount < self.maxConcurrent && self.pendingUnits.count > 0) {
        TurboAdUnitModel *unit = self.pendingUnits.firstObject;
        [self.pendingUnits removeObjectAtIndex:0];
        self.currentLoadingCount++;
        
        [self loadUnit:unit];
    }
}

- (void)loadUnit:(TurboAdUnitModel *)unit {
    TurboLogDebug(@"Loading unit: %@ (ecpm level: %ld)", unit.unitID, (long)unit.ecpmLevel);
    
    // 通过 adapterClassName 动态创建适配器
    Class adapterClass = NSClassFromString(unit.adapterClassName);
    if (!adapterClass) {
        TurboLogWarning(@"Adapter class not found: %@, skipping", unit.adapterClassName);
        self.currentLoadingCount--;
        [self loadNextUnit];
        return;
    }
    
    id<TurboAdAdapterProtocol> adapter = [[adapterClass alloc] initWithUnitModel:unit];
    if (!adapter) {
        TurboLogWarning(@"Failed to create adapter for: %@", unit.adapterClassName);
        self.currentLoadingCount--;
        [self loadNextUnit];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [adapter loadAdWithPlacementModel:self.currentPlacementModel completion:^(BOOL success, id adObject, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        strongSelf.currentLoadingCount--;
        
        if (success && adObject && !strongSelf.loadedAd) {
            TurboLogInfo(@"Ad loaded from unit: %@", unit.unitID);
            
            // 创建广告对象
            TurboAdObject *ad = [TurboAdObject adWithPlacementModel:strongSelf.currentPlacementModel
                                                          unitModel:unit
                                                             format:strongSelf.currentPlacementModel.format];
            ad.customObject = adObject;
            strongSelf.loadedAd = ad;
            
            // 成功加载，停止其他加载
            [strongSelf stopTimeoutTimer];
            [strongSelf completeWithSuccess:ad];
        } else {
            TurboLogDebug(@"Unit %@ failed to load: %@", unit.unitID, error.localizedDescription);
            // 继续加载下一个
            [strongSelf loadNextUnit];
        }
    }];
}

#pragma mark - Timeout

- (NSTimeInterval)totalTimeoutForUnits:(NSArray<TurboAdUnitModel *> *)units {
    NSTimeInterval maxTimeout = 0;
    for (TurboAdUnitModel *unit in units) {
        if (unit.networkTimeout > maxTimeout) {
            maxTimeout = unit.networkTimeout;
        }
    }
    return maxTimeout > 0 ? maxTimeout + 5.0 : 30.0; // 额外 5 秒缓冲
}

- (void)startTimeoutTimer:(NSTimeInterval)timeout {
    [self stopTimeoutTimer];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                        target:self
                                                      selector:@selector(timeoutFired)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (void)stopTimeoutTimer {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)timeoutFired {
    TurboLogWarning(@"Ad loading timeout for placement: %@", self.currentPlacementModel.placementID);
    if (self.loadedAd) {
        [self completeWithSuccess:self.loadedAd];
    } else {
        [self completeWithFailure:[NSError errorWithDomain:kTurboAdErrorDomain
                                                     code:TurboAdErrorCodeTimeout
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Ad loading timeout"}]];
    }
}

#pragma mark - Completion

- (void)completeWithSuccess:(TurboAdObject *)ad {
    if (self.isCompleted) return;
    self.isCompleted = YES;
    
    [self stopTimeoutTimer];
    
    if (self.loadCompletion) {
        self.loadCompletion(YES, ad, nil);
    }
}

- (void)completeWithFailure:(NSError *)error {
    if (self.isCompleted) return;
    self.isCompleted = YES;
    
    [self stopTimeoutTimer];
    
    if (self.loadCompletion) {
        self.loadCompletion(NO, nil, error);
    }
}

- (NSError *)noAdError {
    return [NSError errorWithDomain:kTurboAdErrorDomain
                               code:TurboAdErrorCodeNoAd
                           userInfo:@{NSLocalizedDescriptionKey: @"No ad available for this placement"}];
}

@end
