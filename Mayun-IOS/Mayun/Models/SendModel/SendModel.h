//
//  SendModel.h
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendModel : NSObject<BaseRequestDelegate>

@property(nonatomic,strong) BaseRequest *msgRequest;

+(SendModel *)instance;

-(void)sendPicText:(NSMutableDictionary *)data withPics:(NSArray *)pics;

-(void)sendVideo:(NSMutableDictionary *)data withVideo:(NSData *)video withPic:(NSData *)pic;

@end
