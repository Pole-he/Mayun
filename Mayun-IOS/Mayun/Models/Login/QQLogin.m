//
//  QQLogin.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "QQLogin.h"

static QQLogin *g_instance = nil;

@interface QQLogin()

@end

@implementation QQLogin

+ (QQLogin *)getinstance
{
    @synchronized(self)
    {
        if (nil == g_instance)
        {
            //g_instance = [[sdkCall alloc] init];
            g_instance = [[super allocWithZone:nil] init];
            
        }
    }
    
    return g_instance;
}

- (id)init
{
    NSString *appid = @"100577807";
    _oauth = [[TencentOAuth alloc] initWithAppId:appid
                                     andDelegate:self];
    return self;
}

-(void)loginQQ
{
    //    NSArray *permissions = [NSArray arrayWithObjects:@"get_user_info", @"add_t", nil];
    NSArray *permissions = [NSArray arrayWithObjects:@"all", nil];
    [_oauth authorize:permissions inSafari:NO];
}

- (void)tencentDidLogin
{
    // _labelTitle.text = @"登录完成";
    
    if (_oauth.accessToken && 0 != [_oauth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
        // _labelAccessToken.text = _tencentOAuth.accessToken;
        [_oauth getUserInfo];
        NSLog(@"登录成功");
    }
    else
    {
        // _labelAccessToken.text = @"登录不成功 没有获取accesstoken";
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled)
    {
        // _labelTitle.text = @"用户取消登录";
        NSLog(@"用户取消登录");
    }
    else
    {
        //  _labelTitle.text = @"登录失败";
        NSLog(@"登录失败");
    }
}

-(void)tencentDidNotNetWork
{
    //_labelTitle.text=@"无网络连接，请设置网络";
    NSLog(@"无网络连接，请设置网络");
}

- (void)getUserInfoResponse:(APIResponse*) response
{
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:response.jsonResponse];
    [mdic setObject:_oauth.accessToken forKey:@"accessToken"];
    [mdic setObject:@"QQ" forKey:@"loginType"];
//    NSString *nickName = [dic objectForKey:@"nickname"];
//    NSString *faceUrl = [dic objectForKey:@"figureurl_2"];
//    NSString *accessToken = _oauth.accessToken;
    
    if ([self.delegate respondsToSelector:@selector(successLogin:)]) {
        [self.delegate successLogin:mdic];
    }
    
}


@end
