//
//  VideoPaiVC.h
//  PaiPai
//
//  Created by Nathan-he on 15/2/9.
//  Copyright (c) 2015年 Nathan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoPaiVC : UIViewController<AVCaptureFileOutputRecordingDelegate>

@property(nonatomic,strong) NSString *code;

@end
