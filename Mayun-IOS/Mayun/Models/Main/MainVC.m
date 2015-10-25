//
//  MainVC.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "MainVC.h"
#import "UIImageView+WebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ScanVC.h"
#import <POP/POP.h>
#import "LoginVC.h"

@interface MainVC ()
@property (weak, nonatomic) IBOutlet UIImageView *faceIV;
@property (weak, nonatomic) IBOutlet UILabel *nickName;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *takeBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;


@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.user = [ToolClass userInfo];
    
    NSString *nickName = [self.user objectForKey:@"username"];
    NSString *faceUrl = [self.user objectForKey:@"avatar"];
    
    [self.faceIV sd_setImageWithURL:[NSURL URLWithString:faceUrl]];
    self.nickName.text = nickName;
    
    self.faceIV.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exit)];
    [self.faceIV addGestureRecognizer:tap];    
}

-(void)exit
{
    [ToolClass saveUserInfo:nil];
    [self presentViewController:[LoginVC new] animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)clickSendBtn:(id)sender {
    ScanVC *vc = [ScanVC new];
    vc.scantype = SendScanType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickTakeBtn:(id)sender {
    ScanVC *vc = [ScanVC new];
    vc.scantype = TakeScanType;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickMoreBtn:(id)sender {
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
