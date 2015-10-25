//
//  ResultView.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "ResultView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+Emoji.h"

@interface ResultView ()<MBProgressHUDDelegate,BaseRequestDelegate>
{
    MBProgressHUD *HUD;
    BOOL  _isPause;
    UIButton         *_startBtn;
}

@property(nonatomic,weak) UIToolbar *bgBar;
@property(nonatomic,weak) UIScrollView *scrollview;
@property(nonatomic,weak) UIView *videoView;
@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;

@property(nonatomic,strong) BaseRequest *showRequest;

@end

@implementation ResultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *bgiv = [[UIImageView alloc]initWithFrame:frame];
        bgiv.image = [UIImage imageNamed:@"general_bg"];
        [self addSubview:bgiv];
        
        UIToolbar *bg = [[UIToolbar alloc]initWithFrame:frame];
        bg.barStyle = UIBarStyleBlackTranslucent;
        bg.alpha = 1.0;
       // [self addSubview:bg];
        self.bgBar = bg;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setImage:[UIImage imageNamed:@"general_back_icon"] forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(0, 25, 40, 35);
        [cancelBtn addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        
        
        UIScrollView *scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(frame), CGRectGetHeight(frame)-10)];
        scrollview.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollview];
        self.scrollview = scrollview;
        
        
    }
    return self;
}

-(void)searchBmob
{
    
    [self showAPI];
}

-(IBAction)dismissView:(id)sender
{
    self.RemoveBlock();
    
    if (self.player!=nil) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        @try{
            [self.playerItem removeObserver:self forKeyPath:@"status"];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
        }
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.player = nil;
    }
    
    [self removeFromSuperview];
}

-(void)setData:(NSDictionary *)message
{
    NSString *fromphone = [message objectForKey:@"mobile"];
    
    NSString *findname = [self findNameInAddress:fromphone];
    NSString *fromname = findname == nil?[message objectForKey:@"username"]:findname;
    
    NSString *fromface = [message objectForKey:@"avatar"];
    
    NSString *text = [message objectForKey:@"content"];
    
    UIImageView *userBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    userBg.image = [UIImage imageNamed:@"general_to_bg"];
    [self.scrollview addSubview:userBg];
    
    
    UIImageView *faceIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 8, 30, 30)];
    faceIV.layer.cornerRadius = 3;
    faceIV.layer.masksToBounds = YES;
    [faceIV sd_setImageWithURL:[NSURL URLWithString:fromface]];
    
    [self.scrollview addSubview:faceIV];
    
    UILabel *nameLB = [[UILabel alloc]initWithFrame:CGRectMake(60, 13, 100, 21)];
    nameLB.textColor = UIColorFromRGB(0xffffff, 1.0);
    nameLB.text = fromname;

    [self.scrollview addSubview:nameLB];
    
    int length = CGRectGetMaxY(userBg.frame)+10;
    
    
    NSArray *medias = message[@"linkUrls"];
    
    NSMutableArray *pics = [NSMutableArray array];
    NSString *video;
    
    for (NSDictionary *link in medias) {
        NSInteger type = [link[@"type"] integerValue];
        if (type==0) {
            [pics addObject:link];
        }else{
            video = link[@"linkUrl"];
        }
    }
    
    //无视频
    //
    if (video == nil) {
        UILabel *textLB = [[UILabel alloc]initWithFrame:CGRectMake(20, length, self.scrollview.frame.size.width-40, 2)];
        textLB.numberOfLines = 0;
        // textLB.backgroundColor = [UIColor lightGrayColor];
        textLB.textColor = UIColorFromRGB(0xf2f2f2, 1.0);
        textLB.font=[UIFont systemFontOfSize:14];
       // textLB.text = [text decodeEmoji];
        textLB.attributedText = [ToolClass getAttrString:[text decodeEmoji]];
        [textLB sizeToFit];
        [self.scrollview addSubview:textLB];
        
        length +=CGRectGetHeight(textLB.frame)+8;
        
        for (int i=0;i<pics.count;i++) {
            NSDictionary *pic = pics[i];
            int width = [pic[@"width"] intValue];
            int height = [pic[@"height"] intValue];
            
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(20, length,  CGRectGetWidth(self.scrollview.frame)-40, CGRectGetWidth(self.scrollview.frame)*height/width)];
            img.backgroundColor = UIColorFromRGB(0xf2f2f2, 1.0);
            [img sd_setImageWithURL:[NSURL URLWithString:pic[@"linkUrl"]]];
            
            [self.scrollview addSubview:img];
            
            length += CGRectGetHeight(img.frame);
        }
        
    }else
    {
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(20, length, self.scrollview.frame.size.width-40, self.scrollview.frame.size.width-40)];
        [self.scrollview addSubview:bgView];
        
        UIImageView *img = [[UIImageView alloc]initWithFrame:bgView.bounds];
        [img sd_setImageWithURL:[NSURL URLWithString:pics[0]]];
        img.layer.cornerRadius = 5;
        img.layer.masksToBounds = YES;
        [bgView addSubview:img];
        
//        HUD = [[MBProgressHUD alloc] initWithView:bgView];
//        [bgView addSubview:HUD];
//        
//        // Set determinate mode
//        HUD.mode = MBProgressHUDModeDeterminate;
//        
//        HUD.delegate = self;
//        HUD.labelText = @"Loading";
        //[HUD show:YES];
        
        
        self.player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:video]];
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        
        playerLayer.frame = bgView.bounds;
        playerLayer.cornerRadius = 5;
        playerLayer.masksToBounds = YES;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        [bgView.layer addSublayer:playerLayer];
        
        [self.player setAllowsExternalPlayback:YES];
        
        [self.player seekToTime:kCMTimeZero];
        [self.player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.player currentItem]];
        
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:[UIImage imageNamed:@"btn_play_bg_a"] forState:UIControlStateNormal];
        _startBtn.tag=0;
        _startBtn.backgroundColor=[UIColor colorWithWhite:0.0 alpha:0.5];
        _startBtn.frame=bgView.bounds;
        _startBtn.layer.cornerRadius = 5;
        [_startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:_startBtn];

        
        
        
        length += CGRectGetHeight(bgView.frame)+8;
        
        UILabel *textLB = [[UILabel alloc]initWithFrame:CGRectMake(20, length+10, self.scrollview.frame.size.width-40, 2)];
        textLB.numberOfLines = 0;
        // textLB.backgroundColor = [UIColor lightGrayColor];
        textLB.textColor = UIColorFromRGB(0xf2f2f2, 1.0);
        textLB.font=[UIFont systemFontOfSize:14];
        textLB.attributedText = [ToolClass getAttrString:text];
        [textLB sizeToFit];
        [self.scrollview addSubview:textLB];
        length +=CGRectGetHeight(textLB.frame)+8;
    }
    
    self.scrollview.contentSize = CGSizeMake(CGRectGetWidth(self.scrollview.frame), length+10);
    
    
}

//查找真实姓名
-(NSString *)findNameInAddress:(NSString *)phone
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    //等待同意后向下执行
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    for (int i=0;i<ABAddressBookGetPersonCount(addressBook); i++) {
        ABRecordRef lRef = CFArrayGetValueAtIndex(people, i);
        
        ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(lRef, kABPersonPhoneProperty);
        NSArray* phoneNumbers1 = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(phoneNumberProperty);
        CFRelease(phoneNumberProperty);
        
        // Do whatever you want with the phone numbers
        if(phoneNumbers1 && [phoneNumbers1 isKindOfClass:[NSArray class]]) {
            for(NSString *stringPhoneNUmber in phoneNumbers1) {
                
                NSString *phoneNO = [stringPhoneNUmber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                
                phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                
                phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                if([phoneNO isEqualToString:phone]){
                    // found = YES;
                    //获取联系人姓名
                    NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(lRef);
                    return name;
                }
            }
        }
    }
    return nil;
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

#pragma mark - 加载视频完成
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        if (AVPlayerItemStatusReadyToPlay == self.player.currentItem.status)
        {
            // [self.player play];
            
            
            NSLog(@"准备播放");
            [self startPlay];
            
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    //    AVPlayerItem *p = [notification object];
    //    [p seekToTime:kCMTimeZero];
    [self endPlay];
}

-(void)startBtnClick:(UIButton *)sender
{
    
    switch (sender.tag) {
        case 0:
            [self startPlay];//开始
            break;
        case 1:
            [self rePlay];//重播
            break;
            
        case 2:
            [self continuePlay];//继续播放
            break;
            
        case 3:
            [self pauesPlay];//暂停
            break;
            
        default:
            break;
    }
    
}

#pragma mark - 播放器状态
//重播
-(void)rePlay
{
    _startBtn.tag=3;
    [_startBtn setImage:nil forState:UIControlStateNormal];
    _startBtn.backgroundColor=[UIColor clearColor];
    
    
    AVPlayerItem *playerItem = [self.player currentItem];
    // Set it back to the beginning
    [playerItem seekToTime: kCMTimeZero];
    // Tell the player to do nothing when it reaches the end of the video
    // -- It will come back to this method when it's done
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    // Play it again, Sam
    [self.player play];
    
    _isPause=NO;
    
}

//继续播放
-(void)continuePlay
{
    _startBtn.tag=3;
    [_startBtn setImage:nil forState:UIControlStateNormal];
    _startBtn.backgroundColor=[UIColor clearColor];
    [self.player play];
    _isPause=NO;
    
    
}

//暂停播放
-(void)pauesPlay
{
    _isPause=YES;
    _startBtn.tag=2;
    [_startBtn setImage:[UIImage imageNamed:@"general_play_icon"] forState:UIControlStateNormal];
    _startBtn.backgroundColor=[UIColor colorWithWhite:0.5 alpha:0.5];
    [self.player pause];
    
}

//开始播放
-(void)startPlay
{
    
    _startBtn.tag=3;
    [_startBtn setImage:nil forState:UIControlStateNormal];
    _startBtn.backgroundColor=[UIColor clearColor];
    [self.player play];
    
    _isPause=NO;
    
}

//结束播放
-(void)endPlay
{
    _startBtn.tag=1;
    [_startBtn setImage:[UIImage imageNamed:@"general_play_icon"] forState:UIControlStateNormal];
    _startBtn.backgroundColor=[UIColor colorWithWhite:0.5 alpha:0.5];
}

#pragma mark API Request

-(void)showAPI
{
    if (self.showRequest) {
        [self.showRequest cancel];
    }
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[ToolClass getMyPhone] forKey:@"toMobile"];
    [dic setObject:self.code forKey:@"codeUrl"];
    
    BaseRequest * request =[[BaseRequest alloc]init];
    request.delegate =self;
    request.agrs = dic;
    request.host = HOST;
    request.requestMethod = HTTP_POST_Request;
    request.actionKey =GET_MSG;
    self.showRequest = request;
    [request start];
    
}

#pragma mark BaseRequestDelegate

- (void)request:(BaseRequest *)request successLoadData:(NSMutableDictionary *)dic
{
    [self setData:dic[@"message"]];
}

- (void)request:(BaseRequest *)request failedWithError:(NSString *)error
{
    
}

@end
