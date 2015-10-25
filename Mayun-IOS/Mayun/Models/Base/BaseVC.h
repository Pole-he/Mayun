//
//  BaseVC.h
//  Care
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseVC : UIViewController

-(void)setBaseBackWith:(NSString *)titleName;

- (void)setBaseVCAttributesWith:(NSString *)titleName left:(NSString *)nameLeft right:(NSString *)nameRight;

-(void)setBaseBackWith:(NSString *)titleName right:(NSString *)nameRight;
@end
