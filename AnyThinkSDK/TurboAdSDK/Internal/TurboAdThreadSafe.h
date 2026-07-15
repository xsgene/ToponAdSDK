//
//  TurboAdThreadSafe.h
//  TurboAdSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// GCD barrier queue 实现的线程安全读写容器
@interface TurboAdThreadSafeDictionary<__covariant KeyType, __covariant ObjectType> : NSObject

- (instancetype)initWithQueueLabel:(NSString *)label;

- (nullable ObjectType)objectForKey:(KeyType)key;
- (void)setObject:(nullable ObjectType)obj forKey:(KeyType)key;
- (void)removeObjectForKey:(KeyType)key;
- (void)removeAllObjects;
- (NSArray<KeyType> *)allKeys;
- (NSArray<ObjectType> *)allValues;
- (NSUInteger)count;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(KeyType key, ObjectType obj, BOOL *stop))block;

@end

@interface TurboAdThreadSafeArray<__covariant ObjectType> : NSObject

- (instancetype)initWithQueueLabel:(NSString *)label;

- (void)addObject:(ObjectType)object;
- (void)removeObject:(ObjectType)object;
- (void)removeAllObjects;
- (nullable ObjectType)objectAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (NSArray<ObjectType> *)allObjects;

@end

NS_ASSUME_NONNULL_END
