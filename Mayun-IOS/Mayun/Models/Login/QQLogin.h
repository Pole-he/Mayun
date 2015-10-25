//
//  QQLogin.h
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>

@protocol LoginDelegate <NSObject>

-(void)successLogin:(NSDictionary *) user;

@end

@interface QQLogin : NSObject<TencentSessionDelegate>

@property (nonatomic, strong)TencentOAuth *oauth;
@property (nonatomic , weak) id<LoginDelegate> delegate;

+(QQLogin *)getinstance;
-(void)loginQQ;

@end
