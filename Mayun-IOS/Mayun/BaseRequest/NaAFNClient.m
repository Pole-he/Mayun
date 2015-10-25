//
//  NaAFNClient.m
//  Etoubao
//
//  Created by Nathan-he on 14/11/1.
//  Copyright (c) 2014年 Nathan. All rights reserved.
//

#import "NaAFNClient.h"

@implementation NaAFNClient

//单例初始化
+ (NaAFNClient *)sharedClient
{
    static NaAFNClient *_naClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"BlueMobi iOS team"}];
        
        //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        
        [config setURLCache:cache];
        
        _naClient = [[NaAFNClient alloc] initWithBaseURL:nil
                                    sessionConfiguration:config];
     //   _naClient.requestSerializer.stringEncoding = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);;
        _naClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return _naClient;
}

//post请求
- (NSURLSessionDataTask *)postRequest:(NSString *)url parameters:(id)parameters completion:( void (^)(id result, NSError *error) )completion
{
    NSURLSessionDataTask *task = [self POST:url
                                 parameters:parameters
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                        if (httpResponse.statusCode == 200) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(responseObject, nil);
                                            });
                                        } else {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                completion(nil, nil);
                                            });
                                            NSLog(@"Received: %@", responseObject);
                                            NSLog(@"Received HTTP %ld", (long)httpResponse.statusCode);
                                        }
                                        
                                        
                                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            completion(nil, error);
                                        });
                                    }];
    return task;
}

//get请求
- (NSURLSessionDataTask *)getRequest:(NSString *)url parameters:(id)parameters completion:( void (^)(id result, NSError *error) )completion
{
    NSURLSessionDataTask *task = [self GET:url
                                parameters:parameters
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                       if (httpResponse.statusCode == 200) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(responseObject, nil);
                                           });
                                       } else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, nil);
                                           });
                                           NSLog(@"Received: %@", responseObject);
                                           NSLog(@"Received HTTP %ld", (long)httpResponse.statusCode);
                                       }
                                       
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completion(nil, error);
                                       });
                                   }];
    return task;
}

//上传data
- (NSURLSessionDataTask *)dataRequest:(NSString *)url parameters:(id)parameters data:(NSData *)data completion:( void (^)(id result, NSError *error) )completion
{
    NSURLSessionDataTask *task = [self POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (data) {
            [formData appendPartWithFileData:data
                                        name:@"file"
                                    fileName:@"image.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(responseObject, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
            NSLog(@"Received: %@", responseObject);
            NSLog(@"Received HTTP %ld", (long)httpResponse.statusCode);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    return task;
}

//上传多个文件
- (NSURLSessionDataTask *)dataRequest:(NSString *)url parameters:(id)parameters datas:(NSArray *)datas completion:( void (^)(id result, NSError *error) )completion
{
    NSURLSessionDataTask *task = [self POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (datas.count>0) {
            for (NSDictionary *dic in datas) {
                
                NSString *filename = dic[@"filename"];
                NSString *mimeType ;
                if ([filename hasSuffix:@".mp4"]) {
                    mimeType = @"video/mpeg4";
                }
                else{
                    mimeType = @"image/jpeg";
                }
                [formData appendPartWithFileData:dic[@"data"]
                                            name:@"file"
                                        fileName:dic[@"filename"]
                                        mimeType:mimeType];
            }
        }

    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(responseObject, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
            NSLog(@"Received: %@", responseObject);
            NSLog(@"Received HTTP %ld", (long)httpResponse.statusCode);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    return task;
}

@end
