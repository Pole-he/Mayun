//
//  ResultView.h
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultView : UIView

@property(nonatomic,strong) NSString *code;

@property(nonatomic,strong) void (^RemoveBlock) ();

-(void)searchBmob;

@end
