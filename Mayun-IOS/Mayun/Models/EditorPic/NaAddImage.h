//
//  NaAddImage.h
//  Upairs_4.0
//
//  Created by Nathan-he on 14-6-24.
//  Copyright (c) 2014年 echoliv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NaAddImage : UIView
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic,strong) void (^HeightBlock) ();

-(void)addImage:(UIImage *)img;

-(void)addArrImage:(NSArray *)imgs;
@end
