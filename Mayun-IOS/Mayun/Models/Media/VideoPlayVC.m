//
//  VideoPlayVC.m
//  PaiPai
//
//  Created by Nathan-he on 15/2/11.
//  Copyright (c) 2015年 Nathan. All rights reserved.
//

#import "VideoPlayVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "JDStatusBarNotification.h"
#import "SendModel.h"
#import "UITextView+Placeholder.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>
#import "NSString+Emoji.h"

#define COUNT_DUR_TIMER_INTERVAL  0.025

@interface VideoPlayVC ()<UIAlertViewDelegate,ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>
{
    
    UIProgressView   *_progressView;
    UIButton         *_startBtn;
    NSTimer          *_timer;
    NSInteger         _int_count;//播放时间
    
    BOOL  _playBeginState;
    BOOL  _isPause;
}

@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic ,weak) UITextView *contentTV;

@property (weak, nonatomic)  UIView *toView;
@property (weak, nonatomic)  UILabel *toLB;

@property (nonatomic,strong) NSString *toName;
@property (nonatomic,strong) NSString *toPhone;

@end

@implementation VideoPlayVC

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBaseBackWith:@"" right:@"Send"];


    
    [self initPlayer];//创建播放器
    [self initView];//创建按钮 进度
    
    //播放结束
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playerItemDidReachEnd:)
                                                 name: AVPlayerItemDidPlayToEndTimeNotification
                                               object: self.playerItem];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    @try{
//        [self.playerItem removeObserver:self forKeyPath:@"status"];
//    }@catch(id anException){
//        //do nothing, obviously it wasn't attached because an exception was thrown
//    }
//    [self.player replaceCurrentItemWithPlayerItem:nil];
//    self.player = nil;
}

-(void)initPlayer
{
    
    
    AVURLAsset *movieAsset    = [[AVURLAsset alloc]initWithURL:self.fileURL options:nil];
    
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:NULL];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    playerLayer.frame = CGRectMake(ScreenWidth-150, 84, 140, 140);
    playerLayer.cornerRadius = 5;
    playerLayer.masksToBounds = YES;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.view.layer addSublayer:playerLayer];
    
    [self.player setAllowsExternalPlayback:YES];
    
    
    
}
-(void)initView
{
    
    _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startBtn setImage:[UIImage imageNamed:@"general_play_icon"] forState:UIControlStateNormal];
    _startBtn.tag=0;
    _startBtn.backgroundColor=[UIColor colorWithWhite:0.0 alpha:0.7];
    _startBtn.frame=CGRectMake(ScreenWidth-150, 84, 140, 140);
    _startBtn.layer.cornerRadius = 5;
    [_startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startBtn];
    
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 50, 320, 10)];
    _progressView.progress=0;
  //  [self.view addSubview:_progressView];
    
    UITextView *text = [[UITextView alloc]initWithFrame:CGRectMake(16, 84, CGRectGetMinX(_startBtn.frame)-10, 200)];
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    text.placeholder = @"Think about...";
    text.placeholderColor = UIColorFromRGB(0xf0f0f0, 1.0); // optional
    [self.view addSubview:text];
    self.contentTV = text;
    
    //发送人
    UIView *toView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(text.frame)+16, ScreenWidth , 40)];
    self.toView = toView;
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:toView.bounds];
    bg.image = [UIImage imageNamed:@"general_to_bg"];
    [toView addSubview:bg];
    
    UILabel *toLb = [[UILabel alloc]init];
    toLb.text = @"To:";
    toLb.textColor = [UIColor whiteColor];
    toLb.font = [UIFont systemFontOfSize:17];
    [toLb sizeToFit];
    toLb.center = CGPointMake(toLb.frame.size.width/2+5, CGRectGetHeight(toView.frame)/2);
    [toView addSubview:toLb];
    self.toLB = toLb;
    
    UIImageView *arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"general_arrow_icon"]];
    arrow.frame = CGRectMake(toView.frame.size.width-20, 13, 8, 12);
    [toView addSubview:arrow];
    
    [self.view addSubview:toView];
    
    UITapGestureRecognizer *toTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toAddressBook:)];
    [self.toView addGestureRecognizer:toTap];
}



- (void)leftSelectedEvent:(id)sender
{
    [self cancelVideo:nil];
}

- (void)rightSelectedEvent:(id)sender
{
    [self sendVideo:nil];
}

- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

#pragma mark - BtnClick

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

-(void)resetNotif
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    @try{
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
}

//发布Video
-(IBAction)sendVideo:(id)sender
{
    
    if (self.toName==nil || self.toPhone==nil)
    {
        [JDStatusBarNotification showWithStatus:@"Please input \"To\"" dismissAfter:1.0f styleName:@"JDStatusBarStyleError"];
        return;
    }
    
    [self resetNotif];
    
    
    UIImage *cover = [self thumbnailImageForVideo:self.fileURL atTime:1];
    cover = [self imageWithMaxSide:self.view.frame.size.width sourceImage:cover];
    
    NSData *coverData = UIImagePNGRepresentation(cover);
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSDictionary *user = [ToolClass userInfo];
    
    [data setObject:self.code forKey:@"codeUrl"];

    [data setObject:self.toPhone forKey:@"toMobile"];
    [data setObject:self.toName forKey:@"toUsername"];
    [data setObject:[self.contentTV.text encodeEmoji]  forKey:@"content"];
    
    
    NSMutableArray *datas = [NSMutableArray array];
    
    NSString *photoName=[NSString stringWithFormat:@"%@_%dx%d.jpg",[[NSUUID UUID] UUIDString],(int)cover.size.width,(int)cover.size.height];
        
    NSDictionary *picDic = [[NSDictionary alloc] initWithObjectsAndKeys:photoName,@"filename",coverData,@"data",nil];
    
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4",[[NSUUID UUID] UUIDString]];
    NSDictionary *videoDic = [[NSDictionary alloc] initWithObjectsAndKeys:videoName,@"filename",[NSData dataWithContentsOfURL:self.fileURL],@"data",nil];

    [datas addObject:picDic];
    
    [datas addObject:videoDic];
    
    [[SendModel instance] sendPicText:data withPics:datas];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)cancelVideo:(id)sender
{
    [self resetNotif];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)toAddressBook:(UITapGestureRecognizer *)tap
{
    if ([[UIDevice currentDevice].systemVersion floatValue]>=9.0) {
        CNContactPickerViewController*contactVC = [[CNContactPickerViewController alloc] init];
        contactVC.delegate = self;
        [self presentViewController:contactVC animated:YES completion:nil];
    }else{
        ABPeoplePickerNavigationController *peoleVC = [[ABPeoplePickerNavigationController alloc] init];
        peoleVC.peoplePickerDelegate = self;
        
        [self presentViewController:peoleVC animated:YES completion:nil];
        
        if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
            peoleVC.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
        }
    }
}

//压缩图片
- (UIImage *)imageWithMaxSide:(CGFloat)length sourceImage:(UIImage *)image
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize imgSize = CWSizeReduce(image.size, length);
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, scale);  // 创建一个 bitmap context
    
    [image drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)
            blendMode:kCGBlendModeNormal alpha:1.0];              // 将图片绘制到当前的 context 上
    
    img = UIGraphicsGetImageFromCurrentImageContext();            // 从当前 context 中获取刚绘制的图片
    UIGraphicsEndImageContext();
    
    return img;
}

static inline
CGSize CWSizeReduce(CGSize size, CGFloat limit)   // 按比例减少尺寸
{
    CGFloat max = MAX(size.width, size.height);
    if (max < limit) {
        return size;
    }
    
    CGSize imgSize;
    CGFloat ratio = size.height / size.width;
    
    if (size.width > size.height) {
        imgSize = CGSizeMake(limit, limit*ratio);
    } else {
        imgSize = CGSizeMake(limit/ratio, limit);
    }
    
    return imgSize;
}

#pragma mark - 计时器操作
-(void)startTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

-(void)onTimer
{
    
    if (!_isPause)
    {
        _progressView.progress+=(COUNT_DUR_TIMER_INTERVAL/[self playableDuration]);
    }
    
}
-(void)endTimer
{
    [_timer invalidate];
    _timer=nil;
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
    
    _progressView.progress=0;
    _isPause=NO;
    [self startTimer];
    
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
    [_startBtn setImage:[UIImage imageNamed:@"btn_play_bg_a"] forState:UIControlStateNormal];
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
    
    [self startTimer];
    
    _isPause=NO;
    
}
//结束播放
-(void)endPlay
{
    _startBtn.tag=1;
    [_startBtn setImage:[UIImage imageNamed:@"btn_play_bg_a"] forState:UIControlStateNormal];
    _startBtn.backgroundColor=[UIColor colorWithWhite:0.5 alpha:0.5];
    [self endTimer];
}
#pragma mark - 获取播放的时间
- (NSTimeInterval) playableDuration
{
    
    AVPlayerItem * item = self.playerItem;
    
    if (item.status == AVPlayerItemStatusReadyToPlay) {
        
        return CMTimeGetSeconds(self.playerItem.duration);
        
    }
    else
    {
        
        return(CMTimeGetSeconds(kCMTimeInvalid));
        
    }
    
}

- (NSTimeInterval) playableCurrentTime
{
    AVPlayerItem * item = self.playerItem;
    
    if (item.status == AVPlayerItemStatusReadyToPlay) {
        
        //     NSLog(@"%f\n",CMTimeGetSeconds(self.playerItem.currentTime));
        
        if (!_playBeginState&&CMTimeGetSeconds(self.playerItem.currentTime)==CMTimeGetSeconds(self.playerItem.duration)) {
            
            [self.player pause];
            
        }
        
        _playBeginState = NO;
        
        return CMTimeGetSeconds(self.playerItem.currentTime);
    }
    else
    {
        return(CMTimeGetSeconds(kCMTimeInvalid));
    }
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
            //            NSLog(@"%lf",[self playableDuration]);
            //            [UIView animateWithDuration:[self playableDuration] animations:^{
            //
            //            }];
            
        }
    }
}
#pragma mark - 播放结束时

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    // Loop the video
    
    [self endPlay];//播放停止
    
    //        [self.player play];
    //    }else {
    //        mPlayer.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    //    }
}


#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    
    //获取联系人姓名
    NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@", phoneNO);
    if (phone && phoneNO.length == 11) {
        
        self.toPhone = phoneNO;
        
        self.toName = name;
        
        self.toLB.text = [NSString stringWithFormat:@"To: %@ %@",name,phoneNO];
        [self.toLB sizeToFit];
       // self.toLB.center = CGPointMake(self.toLB.frame.size.width+5, 25);
        
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
        return;
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"请选择正确手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person NS_AVAILABLE_IOS(8_0)
{
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    personViewController.displayedPerson = person;
    
    [peoplePicker pushViewController:personViewController animated:YES];
    
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}



- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person NS_DEPRECATED_IOS(2_0, 8_0)
{
    return YES;
}



- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier NS_DEPRECATED_IOS(2_0, 8_0)
{
    
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    
    //获取联系人姓名
    NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@", phoneNO);
    
    if (phone && phoneNO.length == 11) {
        
        self.toPhone = phoneNO;
        
        self.toName = name;
        
        self.toLB.text = [NSString stringWithFormat:@"To: %@ %@",name,phoneNO];
        
        [self.toLB sizeToFit];
       // self.toLB.center = CGPointMake(self.toLB.frame.size.width+5, 25);
        
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"请选择正确手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    return NO;
}

#pragma mark CNContactPickerDelegate

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
//{
//    NSString *name = [NSString stringWithFormat:@"姓名:%@ %@ %@",contact.givenName,contact.familyName,contact.nameSuffix];
//
//    NSLog(@"name = %@",name);
//
//    for (CNLabeledValue *lv in contact.phoneNumbers) {
//
//        CNPhoneNumber *pNum = lv.value;
//
//
//        NSString *phoneNum = [NSString stringWithFormat:@"\t%@\n",pNum.stringValue];
//
//        NSLog(@"phoneNum = %@",phoneNum);
//    }
//}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    
    //获取联系人姓名
    NSString *name = [NSString stringWithFormat:@"%@%@",contactProperty.contact.familyName,contactProperty.contact.givenName];
    
    CNPhoneNumber *pNum = contactProperty.value;
    
    NSString *phoneNO = pNum.stringValue;
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (phoneNO.length == 11) {
        
        self.toPhone = phoneNO;
        
        self.toName = name;
        
        self.toLB.text = [NSString stringWithFormat:@"To: %@ %@",name,phoneNO];
        [self.toLB sizeToFit];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"请选择正确手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
