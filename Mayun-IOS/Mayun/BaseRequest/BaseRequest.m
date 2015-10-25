//
//  BaseRequest.m
//  LOVO
//
//  Created by Nathan-he on 14-8-28.
//  Copyright (c) 2014年 Nathan. All rights reserved.
//

#import "BaseRequest.h"
#import "NaAFNClient.h"


@interface BaseRequest ()
{
    
    NSURLSessionDataTask *_request;
    NaAFNClient *_client;
}

@end


@implementation BaseRequest

- (void)dealloc
{
    _agrs=nil;
    _host=nil;
    _requestMethod=nil;
    
}

- (id)init
{
    
    self = [super init];
    if (self) {
        _access = false;
        _client = [NaAFNClient sharedClient];
    }
    
    return self;
    
}

//请求开始
- (void)start
{
    //组合请求URL
    NSString *requestURLString = [NSString stringWithFormat:@"%@%@", self.host, self.actionKey];
    
    //交互式请求需要加入UserId
    if (_access) {
        NSString *accessToken = [ToolClass userId];
        if (accessToken) {
            [_agrs setObject:accessToken forKey:@"fromUserId"];
        }
    }
    
    if ([self.requestMethod compare:@"GET" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        
        _request = [_client getRequest:requestURLString parameters:_agrs completion:^(id result, NSError *error) {
            if (result) {
                [self resolveData:result];
            } else {
                NSLog(@"ERROR: %@", error);
                [self resolveError];
            }
        }];
        
    }
    else
    {
        _request = [_client postRequest:requestURLString parameters:_agrs completion:^(id result, NSError *error) {
            if (result) {
                [self resolveData:result];
            } else {
                NSLog(@"ERROR: %@", error);
                [self resolveError];
            }
        }];
    }
    
}

//上传data
-(void)updateData:(NSData *)data
{
    //组合请求URL
    NSString *requestURLString = [NSString stringWithFormat:@"%@%@", self.host, self.actionKey];
    
    //交互式请求需要加入UserId
    if (_access) {
        NSString *accessToken = [ToolClass userId];
        [_agrs setObject:accessToken forKey:@"fromUserId"];
    }
    _request = [_client dataRequest:requestURLString parameters:_agrs data:data completion:^(id result, NSError *error) {
        if (result) {
            [self resolveData:result];
        } else {
            NSLog(@"ERROR: %@", error);
            [self resolveError];
        }
    }];
    
   
}

-(void)updateDatas:(NSArray *)datas
{
    //组合请求URL
    NSString *requestURLString = [NSString stringWithFormat:@"%@%@", self.host, self.actionKey];
    
    //交互式请求需要加入UserId
    if (_access) {
        NSString *accessToken = [ToolClass userId];
        [_agrs setObject:accessToken forKey:@"fromUserId"];
    }
    _request = [_client dataRequest:requestURLString parameters:_agrs datas:datas completion:^(id result, NSError *error) {
        if (result) {
            [self resolveData:result];
        } else {
            NSLog(@"ERROR: %@", error);
            [self resolveError];
        }
    }];
}

// 将JSON串转化为字典或者数组
- (id)toArrayOrNSDictionary:(NSData *)jsonData{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}

//解析返回数据
-(void)resolveData:(id)data
{
    NSMutableDictionary *dic = [self toArrayOrNSDictionary:data];
    //解密JSon
    NSLog(@"=================%s===================",[[dic description]UTF8String]);
    
    if (dic==nil)
    {
        NSLog(@"there is no datas");
        return;
    }
    
    NSInteger status = [[dic objectForKey:@"status"]integerValue];
    //NSString *status = [NSString stringWithFormat:@"%@",[dic objectForKey:@"code"]];
    //NSLog(@"%@",status);
    //成功返回
    if (status == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:successLoadData:)]) {
            [self.delegate request:self successLoadData:[dic objectForKey:@"data"]];
        }
        
    }
    //返回错误信息码
    else if (status == 1) {
        
        NSString *error_code =[dic objectForKey:@"msg"];
        NSLog(@"错误信息=%@",error_code);
        
        NSString *error_msg = [self convertToMsgError:error_code];

        if (self.delegate && [self.delegate respondsToSelector:@selector(request:failedWithError:)]) {
            [self.delegate request:self failedWithError:error_msg];
        }
        
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:failedWithError:)]) {
            [self.delegate request:self failedWithError:@"服务器正在维护中!"];
        }
    }
}

//处理错误
-(void)resolveError
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:failedWithError:)]) {
        [self.delegate request:self failedWithError:@"网络异常,请检查您的网络！"];
    }
}

//取消请求
- (void)cancel
{
    [_request cancel];
    _request = nil;
}


-(NSString *)convertToMsgError:(NSString *)error_code
{
    if ([error_code isEqualToString:@"error_01"]) {
        return @"系统出问题了,工程师抢修中...";
    }else if ([error_code isEqualToString:@"error_02"])
    {
        return @"接口参数错误,麻烦检查一遍";
    }else if ([error_code isEqualToString:@"error_03"])
    {
        return @"用户名或密码错误";
    }
    else if ([error_code isEqualToString:@"error_05"])
    {
        return @"手机号已被注册";
    }
    
    return error_code;
}

@end
