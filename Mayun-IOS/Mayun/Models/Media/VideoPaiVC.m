//
//  VideoPaiVC.m
//  PaiPai
//
//  Created by Nathan-he on 15/2/9.
//  Copyright (c) 2015年 Nathan. All rights reserved.
//

#import "VideoPaiVC.h"
#import "SVProgressHUD.h"
#import "VideoPlayVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SDRecordButton.h"

#define MAX_VIDEO_DUR    10
#define COUNT_DUR_TIMER_INTERVAL  0.025
#define VIDEO_FOLDER    @"videos"

@interface VideoPaiVC ()
{
    
    NSURL *_finashURL;
    MPMoviePlayerController *_player;
    
    float   _float_totalDur;
    float   _float_currentDur;
}
@property(nonatomic,strong)AVCaptureSession      *captureSession;
@property(nonatomic,strong)AVCaptureDeviceInput  *videoDeviceInput;
@property(nonatomic,strong)AVCaptureMovieFileOutput *movieFileOutput;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *preViewLayer;
@property(nonatomic,strong)UIView          *preview;
@property(nonatomic,strong)UIProgressView  *progressView;
@property(nonatomic,strong)NSTimer     *timer;
@property(nonatomic,strong)NSMutableArray     *files;
@property(nonatomic,weak) UIView *toolbar;
@property(nonatomic,weak) UIButton *sureBtn;
@property(nonatomic,weak) UIButton *deleteBtn;
@property (nonatomic, strong)  SDRecordButton *recordButton;

@property(nonatomic,unsafe_unretained)BOOL      isCameraSupported;
@property(nonatomic,unsafe_unretained)BOOL      isTorchSupported;
@property(nonatomic,unsafe_unretained)BOOL      isFrontCameraSupported;


@end

@implementation VideoPaiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor whiteColor];

    
    //创建视频存储目录
    [[self class] createVideoFolderIfNotExist];
    
    
    //用来存储视频路径 以便合成时使用
    self.files=[NSMutableArray array];
    
    //创建视频捕捉窗口
    [self initCapture];
    
    
    //创建录像按钮
    [self initRecordButton];
    
    [self initMenuButton];
    
}


-(void)initCapture
{
    self.captureSession = [[AVCaptureSession alloc]init];
    [_captureSession setSessionPreset:AVCaptureSessionPresetLow];
    
    
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionFront) {
            frontCamera = camera;
        } else {
            backCamera = camera;
        }
    }
    
    if (!backCamera) {
        self.isCameraSupported = NO;
        return;
    } else {
        self.isCameraSupported = YES;
        
        if ([backCamera hasTorch]) {
            self.isTorchSupported = YES;
        } else {
            self.isTorchSupported = NO;
        }
    }
    
    if (!frontCamera) {
        self.isFrontCameraSupported = NO;
    } else {
        self.isFrontCameraSupported = YES;
    }
    
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [backCamera unlockForConfiguration];
    
    self.videoDeviceInput =  [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    
    AVCaptureDeviceInput *audioDeviceInput =[AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    
    [_captureSession addInput:_videoDeviceInput];
    [_captureSession addInput:audioDeviceInput];
    
    
    //output
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    self.movieFileOutput.movieFragmentInterval = kCMTimeInvalid;
    
    [_captureSession addOutput:_movieFileOutput];
    
    //preset
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //preview layer------------------
    self.preViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [_captureSession startRunning];
    
    self.preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame)+2)];
    _preview.clipsToBounds = YES;
    [self.view addSubview:self.preview];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(0,CGRectGetHeight(self.preview.frame)-2, CGRectGetWidth(self.view.frame), 2);
    
    self.progressView.progressTintColor = UIColorFromRGB(0xf01022, 1.0);
    self.progressView.trackTintColor =[UIColor colorWithRed:33/255.0 green:43/255.0 blue:70/255.0 alpha:1.0];
    self.progressView.progress=0;
    [self.preview addSubview:self.progressView];
    
    
    self.preViewLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.preview.frame)-2);
    [self.preview.layer addSublayer:self.preViewLayer];
    
    UIView *tb = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.preview.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.preview.frame))];
    tb.backgroundColor = UIColorFromRGB(0x1d1d1d, 1.0);
    [self.view addSubview:tb];
    
    self.toolbar = tb;
    
    
}



-(void)initRecordButton
{
    
    SDRecordButton *recordBtn = [[SDRecordButton alloc] initWithFrame:CGRectMake(0, 400, 90, 90)];
    recordBtn.center = CGPointMake(CGRectGetMidX(self.toolbar.bounds), CGRectGetMidY(self.toolbar.bounds));
    
    // Configure colors
    recordBtn.buttonColor = [UIColor whiteColor];
    recordBtn.progressColor = UIColorFromRGB(0xf01022, 1.0);
    
    // Add Targets
    [recordBtn addTarget:self action:@selector(recording) forControlEvents:UIControlEventTouchDown];
    [recordBtn addTarget:self action:@selector(pausedRecording) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn addTarget:self action:@selector(pausedRecording) forControlEvents:UIControlEventTouchUpOutside];
    [self.toolbar addSubview:recordBtn];
     self.recordButton = recordBtn;
    
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [sureBtn setImage:[UIImage imageNamed:@"video_disable_icon"] forState:UIControlStateDisabled];
    [sureBtn setImage:[UIImage imageNamed:@"video_ok_icon"] forState:UIControlStateNormal];
    [sureBtn setImage:[UIImage imageNamed:@"video_disable_icon"] forState:UIControlStateHighlighted];
    
    sureBtn.frame=CGRectMake(0, 0, 55, 55);
    
    sureBtn.center =CGPointMake(CGRectGetMidX(self.toolbar.bounds)+110, CGRectGetMidY(self.toolbar.bounds));
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.enabled = NO;
    
    self.sureBtn = sureBtn;
    
    [self.toolbar addSubview:sureBtn];
    
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [deleteBtn setImage:[UIImage imageNamed:@"video_back_icon"] forState:UIControlStateNormal];
    
    deleteBtn.frame=CGRectMake(0, 0, 55, 55);
    
    deleteBtn.center =CGPointMake(CGRectGetMidX(self.toolbar.bounds)-110, CGRectGetMidY(self.toolbar.bounds));
    [deleteBtn addTarget:self action:@selector(deleteVideo) forControlEvents:UIControlEventTouchUpInside];
    self.deleteBtn = deleteBtn;
    
    [self.toolbar addSubview:deleteBtn];
    
}

-(void)initMenuButton
{
    UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake(8, 28, 44, 44);
    [flashBtn setImage:[UIImage imageNamed:@"video_light_off_icon"] forState:UIControlStateNormal];
    [self.view addSubview:flashBtn];
    
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-52, 28, 44, 44);
    [switchBtn setImage:[UIImage imageNamed:@"video_replace_icon"] forState:UIControlStateNormal];
    [self.view addSubview:switchBtn];
    
    [flashBtn addTarget:self action:@selector(switchFlashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [switchBtn addTarget:self action:@selector(switchCameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)switchFlashButtonPressed:(UIButton *)sender {
    
    switch (self.videoDeviceInput.device.torchMode) {
        case AVCaptureTorchModeOff:
            [self setTorchMode:AVCaptureTorchModeOn];
            [sender setImage:[UIImage imageNamed:@"video_light_on_icon"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeOn:
            [self setTorchMode:AVCaptureTorchModeAuto];
            [sender setImage:[UIImage imageNamed:@"video_light_auto_icon"] forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeAuto:
            [self setTorchMode:AVCaptureTorchModeOff];
            [sender setImage:[UIImage imageNamed:@"video_light_off_icon"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (IBAction)switchCameraButtonPressed:(UIButton *)sender {
    if ([self canSwitchCameras]) {
        [self switchCameras];
    }
}

-(void)play
{
    VideoPlayVC *playVideoVC=[[VideoPlayVC alloc]init];
    playVideoVC.fileURL=_finashURL;
    playVideoVC.code = self.code;
    [self.navigationController pushViewController:playVideoVC animated:YES];
}

#pragma mark - BtnClick

-(void)sureBtnClick
{
    
    [SVProgressHUD showWithStatus:@"请稍等..."];
    [self mergeAndExportVideosAtFileURLs:self.files];
    
}

-(void)deleteVideo
{
    if (self.progressView.progress==0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    for(NSURL *fileUrl in self.files)
    {
        [fileManager removeItemAtURL:fileUrl error:nil];
    }
    [self.timer invalidate];
    self.timer = nil;
    self.progressView.progress=0;
    
    [self.recordButton setProgress:0];
    
    _float_totalDur = 0;
    self.sureBtn.enabled = NO;
}

- (void)recording {
    NSURL *fileURL = [NSURL fileURLWithPath:[[self class] getVideoSaveFilePathString]];
    [self.files addObject:fileURL];
    
    
    
    [_movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

- (void)pausedRecording {
    [_movieFileOutput stopRecording];
    [self stopCountDurTimer];
}



- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (BOOL)switchCameras {
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *videoInput =
    [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (videoInput) {
        [self.captureSession beginConfiguration];
        
        [self.captureSession removeInput:self.videoDeviceInput];
        
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.videoDeviceInput = videoInput;
        }
        else {
            [self.captureSession addInput:self.videoDeviceInput];
        }
        
        [self.captureSession commitConfiguration];
    }
    else {
        
        return NO;
    }
    
    
    return YES;
}

- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if (self.videoDeviceInput.device.position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

//闪光灯
- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = self.videoDeviceInput.device;
    
    if (device.torchMode != torchMode &&
        [device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
    }
}


#pragma mark - 获取视频大小及时长

//此方法可以获取文件的大小，返回的是单位是KB。
- (CGFloat) getFileSize:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init] ;
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path])
    {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }
    return filesize;
}

//此方法可以获取视频文件的时长
- (CGFloat) getVideoLength:(NSURL *)URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}


+ (NSString *)getVideoSaveFilePathString
{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //  NSString *path = [paths objectAtIndex:0];
    
    NSString *path =[NSString stringWithFormat:@"%@/tmp/",NSHomeDirectory()];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = @"yyyyMMddHHmmss";
    
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    
    return fileName;
    
}

+ (BOOL)createVideoFolderIfNotExist
{
    // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path =[NSString stringWithFormat:@"%@/tmp/",NSHomeDirectory()];
    
    //[paths objectAtIndex:0];
    
    NSString *folderPath = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建图片文件夹失败");
            return NO;
        }
        return YES;
    }
    return YES;
}

#pragma mark - 合成文件
- (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray
{
    NSError *error = nil;
    
    CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    //先去assetTrack 也为了取renderSize
    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
    
    
    for (NSURL *fileURL in fileURLArray)
    {
        
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        
        if (!asset) {
            continue;
        }
        NSLog(@"%@---%@",[asset tracksWithMediaType:AVMediaTypeAudio],[asset tracksWithMediaType:@"vide"]);
        
        [assetArray addObject:asset];
        
        
        AVAssetTrack *assetTrack = [[asset tracksWithMediaType:@"vide"] objectAtIndex:0];
        
        [assetTrackArray addObject:assetTrack];
        
        renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
        renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
    }
    
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    
    for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
        
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:[asset tracksWithMediaType:AVMediaTypeAudio].count>0?[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]:nil
                             atTime:totalDuration
                              error:nil];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetTrack
                             atTime:totalDuration
                              error:&error];
        
        //fix orientationissue
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        CGFloat rate;
        rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));//向上移动取中部影响
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
        
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        //data
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    //get save path
    NSString *filePath = [[self class] getVideoMergeFilePathString];
    
    NSURL *mergeFileURL = [NSURL fileURLWithPath:filePath];
    
    //export
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW);//重新设定尺寸
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _finashURL=mergeFileURL;
            [SVProgressHUD dismiss];
            [self deleteVideo];
            [self play];
            //保存本地
            //UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
            
            
            //            if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishMergingVideosToOutPutFileAtURL:)]) {
            //                [_delegate videoRecorder:self didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
            //            }
        });
    }];
}

+ (NSString *)getVideoMergeFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //  NSLog(@"",);
    NSString *path =[NSString stringWithFormat:@"%@/tmp/",NSHomeDirectory()];
    // [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    return fileName;
}
#pragma mark - 计时器操作

- (void)startCountDurTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)onTimer:(NSTimer *)timer
{
    
    _float_totalDur+=COUNT_DUR_TIMER_INTERVAL;
    
    NSLog(@"%lf ----  %lf",_float_totalDur,self.progressView.progress);
    
    if (_float_totalDur>MAX_VIDEO_DUR/2) {
        self.sureBtn.enabled = YES;
    }else{
        self.sureBtn.enabled = NO;
    }
    
    self.progressView.progress = _float_totalDur/MAX_VIDEO_DUR ;
    
    [self.recordButton setProgress:_float_totalDur/MAX_VIDEO_DUR];
    
    if(self.progressView.progress==1)
    {
        [self pausedRecording];
        [self performSelector:@selector(sureBtnClick) withObject:nil afterDelay:1];
        
    }
    
    
}
- (void)stopCountDurTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - AVCaptureFileOutputRecordignDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    [self startCountDurTimer];
    NSLog(@"didStartRecordingToOutputFileAtURL");
    
    //    self.currentFileURL = fileURL;
    //
    //    self.currentVideoDur = 0.0f;
    //    [self startCountDurTimer];
    //
    //    if ([_delegate respondsToSelector:@selector(videoRecorder:didStartRecordingToOutPutFileAtURL:)]) {
    //        [_delegate videoRecorder:self didStartRecordingToOutPutFileAtURL:fileURL];
    //    }
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    NSLog(@"%@",videoPath);
    
    NSLog(@"%@",error);
    
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    
    NSLog(@"didFinishRecordingToOutputFileAtURL---%lf",_float_totalDur);
    //    self.totalVideoDur += _currentVideoDur;
    //    NSLog(@"本段视频长度: %f", _currentVideoDur);
    //    NSLog(@"现在的视频总长度: %f", _totalVideoDur);
    //
    //    if (!error) {
    //        SBVideoData *data = [[SBVideoData alloc] init];
    //        data.duration = _currentVideoDur;
    //        data.fileURL = outputFileURL;
    //
    //        [_videoFileDataArray addObject:data];
    //    }
    //
    //    if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
    //        [_delegate videoRecorder:self didFinishRecordingToOutPutFileAtURL:outputFileURL duration:_currentVideoDur totalDur:_totalVideoDur error:error];
    //    }
}


@end
