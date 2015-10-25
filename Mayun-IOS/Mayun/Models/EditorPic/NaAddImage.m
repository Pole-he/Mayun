//
//  NaAddImage.m
//  Upairs_4.0
//
//  Created by Nathan-he on 14-6-24.
//  Copyright (c) 2014年 echoliv. All rights reserved.
//

#import "NaAddImage.h"
#import "ZYQAssetPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#define imageH 85 // 图片高度
#define imageW 85 // 图片宽度
#define topMargin 12
#define kMaxColumn 3 // 每行显示数量
#define MaxImageCount 6 // 最多显示图片个数
#define deleImageWH 25 // 删除按钮的宽高
#define kAdeleImage @"wishing_delete_picture_icon" // 删除按钮图片
#define kAddImage @"wishing_add_picture_icon" // 添加按钮图片

@interface NaAddImage()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate,UIActionSheetDelegate>
{
    // 标识被编辑的按钮 -1 为添加新的按钮
    NSInteger editTag;
    NSMutableArray *_imageViews;
}

@end

@implementation NaAddImage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        UIImageView *btn = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kAddImage]];
        btn.userInteractionEnabled = YES;
        btn.contentMode = UIViewContentModeScaleToFill;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editPortrait:)];
        [btn addGestureRecognizer:tap];
        btn.tag = self.subviews.count;
        [self addSubview:btn];
        self.backgroundColor = [UIColor whiteColor];
        
        _imageViews = [NSMutableArray array];
    }
    return self;
}

-(void)awakeFromNib
{
    UIImageView *btn = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kAddImage]];
    btn.userInteractionEnabled = YES;
    btn.contentMode = UIViewContentModeScaleToFill;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editPortrait:)];
    [btn addGestureRecognizer:tap];
    btn.tag = self.subviews.count;
    [self addSubview:btn];
    //self.backgroundColor = [UIColor whiteColor];
    
    _imageViews = [NSMutableArray array];
}

-(void)addImage:(UIImage *)img
{
    NSArray *arr = [NSArray arrayWithObject:img];
    [self addArrImage:arr];
}

-(void)addArrImage:(NSArray *)imgs
{
    for (int i=0; i<imgs.count; i++) {
        UIImageView *imgview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        imgview.contentMode=UIViewContentModeScaleAspectFill;
        imgview.clipsToBounds=YES;
        imgview.tag = self.subviews.count;
        imgview.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeOld:)];
        [imgview addGestureRecognizer:tap];
        // 添加长按手势,用作删除.加号按钮不添加
        if(imgview.tag != 0)
        {
            UILongPressGestureRecognizer *gester = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [imgview addGestureRecognizer:gester];
        }
        
        UIImage *tempImg=imgs[i];
        
        [imgview setImage:tempImg];
        [self.images addObject:tempImg];
        [_imageViews addObject:imgview];
        [self insertSubview:imgview atIndex:self.subviews.count - 1];
        if (self.subviews.count - 1 == MaxImageCount)
        {
            [[self.subviews lastObject] setHidden:YES];
        }
    }
}

-(NSMutableArray *)images
{
    if (_images == nil) {
        _images = [NSMutableArray array];
    }
    return _images;
}


// 添加新的控件
- (void)addNew:(UITapGestureRecognizer *)tap
{
    // 标识为添加一个新的图片
    
    if (![self deleClose:(UIImageView *)tap.view]) {
        editTag = -1;
        [self callImagePicker];
    }
    
    
}

// 修改旧的控件
- (void)changeOld:(UITapGestureRecognizer *)tap
{
    // 标识为修改(tag为修改标识)
    if (![self deleClose:(UIImageView *)tap.view]) {
        editTag = tap.view.tag;
        [self tapHandle:tap];
    }
}

- (void)tapHandle:(UITapGestureRecognizer *)tap {
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity: [_imageViews count] ];
    for (int i = 0; i < [_imageViews count]; i++) {
        // 替换为中等尺寸图片
        
        UIImageView *iv = _imageViews[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.image = iv.image;
        photo.srcImageView = iv;
        [photos addObject:photo];
        
        
    }
    
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = [_imageViews indexOfObject:tap.view]; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

// 删除"删除按钮"
- (BOOL)deleClose:(UIImageView *)btn
{
    if (btn.subviews.count == 1) {
        [[btn.subviews lastObject] removeFromSuperview];
        [self stop:btn];
        return YES;
    }
    
    return NO;
}


// 调用图片选择器
- (void)callImagePicker
{
    //    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
    //    pc.allowsEditing = YES;
    //    pc.delegate = self;
    ////    [self.window.rootViewController presentViewController:pc animated:YES completion:nil];
    //    [self.viewController presentViewController:pc animated:YES completion:nil];
    int n = MaxImageCount -(int)self.subviews.count+1;
    if(n<=0)
    {
        return;
    }
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = n;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups=NO;
    picker.delegate=self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 5;
        } else {
            return YES;
        }
    }];
    
    [[ToolClass viewController:self] presentViewController:picker animated:YES completion:NULL];
}

- (void)editPortrait:(UITapGestureRecognizer *)tap
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:[ToolClass viewController:self].view];
}


// 长按添加删除按钮
- (void)longPress : (UIGestureRecognizer *)gester
{
    if (gester.state == UIGestureRecognizerStateBegan)
    {
        UIImageView *btn = (UIImageView *)gester.view;
        
        UIButton *dele = [UIButton buttonWithType:UIButtonTypeCustom];
        dele.bounds = CGRectMake(0, 0, deleImageWH, deleImageWH);
        [dele setImage:[UIImage imageNamed:kAdeleImage] forState:UIControlStateNormal];
        [dele addTarget:self action:@selector(deletePic:) forControlEvents:UIControlEventTouchUpInside];
        dele.frame = CGRectMake(btn.frame.size.width - dele.frame.size.width, 0, dele.frame.size.width, dele.frame.size.height);
        
        [btn addSubview:dele];
        [self start : btn];
        
        
    }
    
}

// 长按开始抖动
- (void)start : (UIImageView *)btn {
    double angle1 = -5.0 / 180.0 * M_PI;
    double angle2 = 5.0 / 180.0 * M_PI;
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"transform.rotation";
    
    anim.values = @[@(angle1),  @(angle2), @(angle1)];
    anim.duration = 0.25;
    // 动画的重复执行次数
    anim.repeatCount = MAXFLOAT;
    
    // 保持动画执行完毕后的状态
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    
    [btn.layer addAnimation:anim forKey:@"shake"];
}

// 停止抖动
- (void)stop : (UIImageView *)btn{
    [btn.layer removeAnimationForKey:@"shake"];
}

// 删除图片
- (void)deletePic : (UIButton *)btn
{
    [self.images removeObject:[(UIImageView *)btn.superview image]];
    [_imageViews removeObject:(UIImageView *)btn.superview];
    [btn.superview removeFromSuperview];
    if ([[self.subviews lastObject] isHidden]) {
        [[self.subviews lastObject] setHidden:NO];
    }
}

// 对所有子控件进行布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    int count = (int)self.subviews.count;
    CGFloat btnW = imageW;
    CGFloat btnH = imageH;
    int maxColumn = kMaxColumn > self.frame.size.width / imageW ? self.frame.size.width / imageW : kMaxColumn;
    CGFloat marginX = (self.frame.size.width - maxColumn * btnW) / (maxColumn + 1);
    CGFloat marginY = marginX;
    for (int i = 0; i < count; i++) {
        UIImageView *btn = self.subviews[i];
        CGFloat btnX = (i % maxColumn) * (marginX + btnW) + marginX;
        CGFloat btnY = (i / maxColumn) * (marginY + btnH) + marginY;
        
        [UIView animateWithDuration:0.3f animations:^{
            
            btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        }];
    }
    
    NSArray *views = self.subviews;
    
    if (views.count>1) {
        
        UIView *last2View = views[views.count-2];
        
        UIView *last1View = views[views.count-1];
        
        CGRect rect = self.frame;
        
        rect.size.height = views.count == 4? CGRectGetMaxY(last1View.frame)+marginY:CGRectGetMaxY(last2View.frame)+marginY;
        self.frame = rect;
        
        self.HeightBlock();
    }
    
}


#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (int i=0; i<assets.count; i++) {
            ALAsset *asset=assets[i];
            UIImageView *imgview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            imgview.contentMode=UIViewContentModeScaleAspectFill;
            imgview.clipsToBounds=YES;
            imgview.tag = self.subviews.count;
            imgview.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeOld:)];
            [imgview addGestureRecognizer:tap];
            // 添加长按手势,用作删除.加号按钮不添加
            if(imgview.tag != 0)
            {
                UILongPressGestureRecognizer *gester = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                [imgview addGestureRecognizer:gester];
            }
            
            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            
            NSLog(@"width = %f , height = %f",tempImg.size.width,tempImg.size.height);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [imgview setImage:tempImg];
                [self.images addObject:tempImg];
                [_imageViews addObject:imgview];
                [self insertSubview:imgview atIndex:self.subviews.count - 1];
                if (self.subviews.count - 1 == MaxImageCount)
                {
                    [[self.subviews lastObject] setHidden:YES];
                }
            });
        }
    });
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [[ToolClass viewController:self] presentViewController:controller
                                                          animated:YES
                                                        completion:^(void){
                                                            NSLog(@"Picker View Controller is presented");
                                                        }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            // 标识为添加一个新的图片
            [self callImagePicker];
            
        }
    }
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            UIImageView *imgview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            imgview.contentMode=UIViewContentModeScaleAspectFill;
            imgview.clipsToBounds=YES;
            imgview.tag = self.subviews.count;
            imgview.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeOld:)];
            [imgview addGestureRecognizer:tap];
            // 添加长按手势,用作删除.加号按钮不添加
            if(imgview.tag != 0)
            {
                UILongPressGestureRecognizer *gester = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
                [imgview addGestureRecognizer:gester];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [imgview setImage:portraitImg];
                [self.images addObject:portraitImg];
                [_imageViews addObject:imgview];
                [self insertSubview:imgview atIndex:self.subviews.count - 1];
                if (self.subviews.count - 1 == MaxImageCount)
                {
                    [[self.subviews lastObject] setHidden:YES];
                }
            });
            
        });
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}


@end
