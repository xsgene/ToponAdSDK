//
//  TurboAdNetworking.m
//  TurboAdSDK
//

#import "TurboAdNetworking.h"
#import "TurboAdLogger.h"

@implementation TurboAdNetworking

+ (instancetype)sharedManager {
    static TurboAdNetworking *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (void)GET:(NSString *)URLString
 parameters:(NSDictionary *)parameters
    headers:(NSDictionary<NSString *, NSString *> *)headers
 completion:(TurboAdNetworkCompletion)completion {
    
    NSURL *url = [self buildURLWithString:URLString parameters:parameters];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 30;
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    TurboLogDebug(@"GET Request: %@", url.absoluteString);
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                TurboLogError(@"GET Request failed: %@, error: %@", url.absoluteString, error.localizedDescription);
            } else {
                TurboLogDebug(@"GET Request success: %@", url.absoluteString);
            }
            if (completion) {
                completion(data, response, error);
            }
        });
    }];
    [task resume];
}

- (void)POST:(NSString *)URLString
  parameters:(NSDictionary *)parameters
     headers:(NSDictionary<NSString *, NSString *> *)headers
    bodyData:(NSData *)bodyData
  completion:(TurboAdNetworkCompletion)completion {
    
    NSURL *url = [self buildURLWithString:URLString parameters:parameters];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30;
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    if (bodyData) {
        request.HTTPBody = bodyData;
    }
    
    TurboLogDebug(@"POST Request: %@", url.absoluteString);
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                TurboLogError(@"POST Request failed: %@, error: %@", url.absoluteString, error.localizedDescription);
            } else {
                TurboLogDebug(@"POST Request success: %@", url.absoluteString);
            }
            if (completion) {
                completion(data, response, error);
            }
        });
    }];
    [task resume];
}

- (void)downloadImageWithURL:(NSString *)URLString
                  completion:(void(^)(UIImage *image, NSError *error))completion {
    
    NSURL *url = [NSURL URLWithString:URLString];
    if (!url) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"TurboAdSDK" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid URL"}]);
        }
        return;
    }
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:[NSURLRequest requestWithURL:url]
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                TurboLogError(@"Image download failed: %@, error: %@", URLString, error.localizedDescription);
                if (completion) completion(nil, error);
                return;
            }
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                TurboLogDebug(@"Image downloaded successfully: %@", URLString);
            } else {
                TurboLogWarning(@"Failed to create image from data: %@", URLString);
            }
            if (completion) completion(image, nil);
        });
    }];
    [task resume];
}

#pragma mark - Private

- (NSURL *)buildURLWithString:(NSString *)URLString parameters:(NSDictionary *)parameters {
    if (!parameters || parameters.count == 0) {
        return [NSURL URLWithString:URLString];
    }
    
    NSMutableArray *queryItems = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *encodedKey = [(NSString *)key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *encodedValue = [(NSString *)value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [queryItems addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
    }];
    
    NSString *queryString = [queryItems componentsJoinedByString:@"&"];
    NSString *urlWithQuery = [NSString stringWithFormat:@"%@?%@", URLString, queryString];
    return [NSURL URLWithString:urlWithQuery];
}

@end
