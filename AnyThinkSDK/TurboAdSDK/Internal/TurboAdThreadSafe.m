//
//  TurboAdThreadSafe.m
//  TurboAdSDK
//

#import "TurboAdThreadSafe.h"

#pragma mark - TurboAdThreadSafeDictionary

@interface TurboAdThreadSafeDictionary ()
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation TurboAdThreadSafeDictionary

- (instancetype)initWithQueueLabel:(NSString *)label {
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionary];
        _queue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)init {
    return [self initWithQueueLabel:@"com.turboadsdk.threadsafe.dict"];
}

- (id)objectForKey:(id)key {
    __block id result = nil;
    dispatch_sync(self.queue, ^{
        result = self.dictionary[key];
    });
    return result;
}

- (void)setObject:(id)obj forKey:(id)key {
    dispatch_barrier_async(self.queue, ^{
        if (obj) {
            self.dictionary[key] = obj;
        } else {
            [self.dictionary removeObjectForKey:key];
        }
    });
}

- (void)removeObjectForKey:(id)key {
    dispatch_barrier_async(self.queue, ^{
        [self.dictionary removeObjectForKey:key];
    });
}

- (void)removeAllObjects {
    dispatch_barrier_async(self.queue, ^{
        [self.dictionary removeAllObjects];
    });
}

- (NSArray *)allKeys {
    __block NSArray *keys = nil;
    dispatch_sync(self.queue, ^{
        keys = [self.dictionary allKeys];
    });
    return keys;
}

- (NSArray *)allValues {
    __block NSArray *values = nil;
    dispatch_sync(self.queue, ^{
        values = [self.dictionary allValues];
    });
    return values;
}

- (NSUInteger)count {
    __block NSUInteger count = 0;
    dispatch_sync(self.queue, ^{
        count = self.dictionary.count;
    });
    return count;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    __block NSDictionary *snapshot = nil;
    dispatch_sync(self.queue, ^{
        snapshot = [self.dictionary copy];
    });
    [snapshot enumerateKeysAndObjectsUsingBlock:block];
}

@end

#pragma mark - TurboAdThreadSafeArray

@interface TurboAdThreadSafeArray ()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation TurboAdThreadSafeArray

- (instancetype)initWithQueueLabel:(NSString *)label {
    self = [super init];
    if (self) {
        _array = [NSMutableArray array];
        _queue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)init {
    return [self initWithQueueLabel:@"com.turboadsdk.threadsafe.array"];
}

- (void)addObject:(id)object {
    dispatch_barrier_async(self.queue, ^{
        [self.array addObject:object];
    });
}

- (void)removeObject:(id)object {
    dispatch_barrier_async(self.queue, ^{
        [self.array removeObject:object];
    });
}

- (void)removeAllObjects {
    dispatch_barrier_async(self.queue, ^{
        [self.array removeAllObjects];
    });
}

- (id)objectAtIndex:(NSUInteger)index {
    __block id result = nil;
    dispatch_sync(self.queue, ^{
        if (index < self.array.count) {
            result = self.array[index];
        }
    });
    return result;
}

- (NSUInteger)count {
    __block NSUInteger count = 0;
    dispatch_sync(self.queue, ^{
        count = self.array.count;
    });
    return count;
}

- (NSArray *)allObjects {
    __block NSArray *objects = nil;
    dispatch_sync(self.queue, ^{
        objects = [self.array copy];
    });
    return objects;
}

@end
