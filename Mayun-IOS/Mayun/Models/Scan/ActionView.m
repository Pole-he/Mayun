//
//  ActionView.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "ActionView.h"
#import "FlatButton.h"
#import "MediaTool.h"

@interface ActionView()

@property(nonatomic,weak) UIToolbar *bgBar;
@property(nonatomic,weak) FlatButton *photoBtn;
@property(nonatomic,weak) FlatButton *albumBtn;
@property(nonatomic,weak) FlatButton *videoBtn;

@property(nonatomic,strong) MediaTool *mediatool;
@end

@implementation ActionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIToolbar *bg = [[UIToolbar alloc]initWithFrame:frame];
        bg.barStyle = UIBarStyleBlackTranslucent;
        bg.alpha = 1.0;
        [self addSubview:bg];
        self.bgBar = bg;
        
        int centerY = CGRectGetMidY(self.bounds);
        
        int margin = 40;

        int width = (CGRectGetWidth(frame)-4*margin)/3;
        
        //Photo
        FlatButton *photo = [[FlatButton alloc]initWithFrame:CGRectMake(margin, centerY-width/2, width, width)];
        [photo setTitle:@"Photo" forState:UIControlStateNormal];
        photo.titleLabel.textColor = [UIColor whiteColor];
        photo.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light " size:28.0f];
        photo.titleLabel.textAlignment = NSTextAlignmentCenter;
        photo.layer.cornerRadius = width/3;
        photo.layer.borderWidth = 1;
        photo.layer.borderColor = [[UIColor whiteColor]CGColor];
        self.photoBtn = photo;
        [self addSubview:photo];
        
        //Album
        FlatButton *album = [[FlatButton alloc]initWithFrame:CGRectMake(margin*2+width, centerY-width/2, width, width)];
        [album setTitle:@"Album" forState:UIControlStateNormal];
        album.titleLabel.textColor = [UIColor whiteColor];
        album.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light " size:28.0f];
        album.titleLabel.textAlignment = NSTextAlignmentCenter;
        album.layer.cornerRadius = width/3;
        album.layer.borderWidth = 1;
        album.layer.borderColor = [[UIColor whiteColor]CGColor];
        self.albumBtn = album;
        [self addSubview:album];
        
        //Video
        FlatButton *video = [[FlatButton alloc]initWithFrame:CGRectMake(margin*3+2*width, centerY-width/2, width, width)];
        [video setTitle:@"Video" forState:UIControlStateNormal];
        video.titleLabel.textColor = [UIColor whiteColor];
        video.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Light " size:18.0f];
        video.titleLabel.textAlignment = NSTextAlignmentCenter;
        video.layer.cornerRadius = width/3;
        video.layer.borderWidth = 1;
        video.layer.borderColor = [[UIColor whiteColor]CGColor];
        self.videoBtn = video;
        [self addSubview:video];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelBtn sizeToFit];
        cancelBtn.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(album.frame)+100);
        
        [self addSubview:cancelBtn];
        [cancelBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.photoBtn addTarget:self action:@selector(clickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self.albumBtn addTarget:self action:@selector(clickAlbum:) forControlEvents:UIControlEventTouchUpInside];
        [self.videoBtn addTarget:self action:@selector(clickVideo:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(IBAction)cancelBtn:(id)sender
{
    self.RemoveBlock();
    [self removeFromSuperview];
}

-(IBAction)clickPhoto:(id)sender
{
    
    if (!self.mediatool) {
        UIViewController *vc = [ToolClass viewController:self];
        MediaTool *tool = [MediaTool new];
        tool.vc = vc;
        self.mediatool = tool;
    }
    [self.mediatool takePhoto];
}

-(IBAction)clickAlbum:(id)sender
{
    if (!self.mediatool) {
        UIViewController *vc = [ToolClass viewController:self];
        MediaTool *tool = [MediaTool new];
        tool.vc = vc;
        self.mediatool = tool;
    }
    [self.mediatool takeAlbum];
}

-(IBAction)clickVideo:(id)sender
{
    if (!self.mediatool) {
        UIViewController *vc = [ToolClass viewController:self];
        MediaTool *tool = [MediaTool new];
        tool.vc = vc;
        self.mediatool = tool;
    }
    [self.mediatool takeVideo];
}

@end
