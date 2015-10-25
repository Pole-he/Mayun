//
//  MediaTool.h
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaTool : NSObject

@property(nonatomic,strong) UIViewController *vc;

-(void)takePhoto;

-(void)takeAlbum;

-(void)takeVideo;
@end
