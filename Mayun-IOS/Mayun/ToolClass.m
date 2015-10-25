//
//  ToolClass.m
//  LOVO
//
//  Created by Nathan-he on 14-8-24.
//  Copyright (c) 2014年 Nathan. All rights reserved.
//

#import "ToolClass.h"

@implementation ToolClass

/**
 * 根据View返回VC
 *
 **/
+ (UIViewController*)viewController:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

//判断手机正则
+ (BOOL) validateMobile:(NSString *)mobile
{
    NSString *mobileRegex = @"^(1([0-9][0-9]))\\d{8}$";
    NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    BOOL isMatch = [mobileTest evaluateWithObject:mobile];
    return isMatch;
}

/**
 * 把用户Dictionary存入NSUserDefaults
 * 标示 @“userInfo”
 **/
+ (void)saveUserInfo:(NSDictionary *)user
{
    //将上述数据全部存储到NSUserDefaults中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setPersistentDomain:user forName:@"userInfo"];
    [userDefaults synchronize];
}

/**
 * 根据标示获取用户的Dictionary
 *
 **/
+(NSDictionary *) userInfo
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return [userDefaultes persistentDomainForName:@"userInfo"];
}

+(NSString *) getMyPhone
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = [userDefaultes persistentDomainForName:@"userInfo"];
    return user[@"mobile"];
}

//获取用户信息
+(NSString *) userId
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary * user = [userDefaultes persistentDomainForName:@"userInfo"];
    
    return user[@"id"];
}


//对长文本进行有效排版
+ (NSMutableAttributedString *)getAttrString:(NSString *)string
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];//调整行间距
    paragraphStyle.alignment = NSTextAlignmentLeft;//对齐方式
//    paragraphStyle.firstLineHeadIndent = 20;//首行头缩进
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    return  attributedString;
}

@end
