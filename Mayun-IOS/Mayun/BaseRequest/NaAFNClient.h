//
//  NaAFNClient.h
//  Etoubao
//
//  Created by Nathan-he on 14/11/1.
//  Copyright (c) 2014年 Nathan. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface NaAFNClient : AFHTTPSessionManager
//单例初始化
+ (NaAFNClient *)sharedClient;
//post请求
- (NSURLSessionDataTask *)postRequest:(NSString *)url parameters:(id)parameters completion:( void (^)(id result, NSError *error) )completion;
//get请求
- (NSURLSessionDataTask *)getRequest:(NSString *)url parameters:(id)parameters completion:( void (^)(id result, NSError *error) )completion;

//上传文件
- (NSURLSessionDataTask *)dataRequest:(NSString *)url parameters:(id)parameters data:(NSData *)data completion:( void (^)(id result, NSError *error) )completion;

//上传多个文件
- (NSURLSessionDataTask *)dataRequest:(NSString *)url parameters:(id)parameters datas:(NSArray *)datas completion:( void (^)(id result, NSError *error) )completion;
@end
