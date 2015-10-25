//
//  ScanVC.h
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ScanType) {
    SendScanType = 0,
    TakeScanType,
};

@interface ScanVC : UIViewController

@property(nonatomic) ScanType scantype;

@property(nonatomic,strong) NSString *code;

@end
