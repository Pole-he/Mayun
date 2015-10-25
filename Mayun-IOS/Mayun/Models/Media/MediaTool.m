//
//  MediaTool.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "MediaTool.h"
#import "EditorPicVC.h"
#import "ZYQAssetPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ScanVC.h"
#import "VideoPaiVC.h"

#define MaxImageCount 6 // 最多显示图片个数

@interface MediaTool()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ZYQAssetPickerControllerDelegate>

@end

@implementation MediaTool

-(void)takeVideo
{
    VideoPaiVC *video = [[VideoPaiVC alloc]init];
    video.code = ((ScanVC *)self.vc).code;
    [self.vc.navigationController pushViewController:video animated:YES];
}

-(void)takePhoto
{
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
//        controller.allowsEditing = YES;
//        controller.showsCameraControls = YES;
        [self.vc presentViewController:controller
                                          animated:YES
                                        completion:^(void){
                                            NSLog(@"Picker View Controller is presented");
                                        }];
    }
}

-(void)takeAlbum
{
    // 从相册中选取
    if ([self isPhotoLibraryAvailable]) {
        // 标识为添加一个新的图片
        [self callImagePicker];
        
    }
}

// 调用图片选择器
- (void)callImagePicker
{

    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = MaxImageCount;
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
    
    [self.vc presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *imgs = [NSMutableArray array];
        for (int i=0; i<assets.count; i++) {
            ALAsset *asset=assets[i];
            
            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            [imgs addObject:tempImg];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            EditorPicVC *vc = [EditorPicVC new];
            vc.imgs = imgs;
            vc.code = ((ScanVC *)self.vc).code;
            [self.vc presentViewController:vc animated:YES completion:nil];
        });
    });
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                EditorPicVC *vc = [EditorPicVC new];
                vc.imgs = [NSArray arrayWithObject:portraitImg];
                vc.code = ((ScanVC *)self.vc).code;
                [self.vc presentViewController:vc animated:YES completion:nil];
            });
            
        });
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
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


@end
