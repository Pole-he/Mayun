//
//  BaseRequest.h
//  LOVO
//
//  Created by Nathan-he on 14-8-28.
//  Copyright (c) 2014年 Nathan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseUrl.h"
#import "AFHTTPRequestOperationManager.h"
#define HTTP_GET_Request @"GET"
#define HTTP_POST_Request @"POST"
#define REQUEST_DEFAULT_TIME_OUT 15

@class BaseRequest;

@protocol BaseRequestDelegate <NSObject>

@optional
//请求延时
- (void)requestTimeOut:(BaseRequest *)request;

@required
//请求成功
- (void)request:(BaseRequest *)request successLoadData:(NSMutableDictionary *)dic;
- (void)request:(BaseRequest *)request failedWithError:(NSString *)error;

@end

@interface BaseRequest : NSObject

@property (nonatomic)BOOL access;
@property (nonatomic,strong)NSMutableDictionary *agrs;  //key值
@property (nonatomic,strong)NSString *host;
@property (nonatomic,strong)NSString *requestMethod;  //分post和get
@property (nonatomic,strong) NSString *actionKey;

@property (nonatomic,weak)id <BaseRequestDelegate> delegate;

@property (nonatomic) NSTimeInterval timeOut; //default is 15s

//开始请求
- (void)start;
//取消请求
- (void)cancel;
//上传data
-(void)updateData:(NSData *)data;

-(void)updateDatas:(NSArray *)datas;
@end
