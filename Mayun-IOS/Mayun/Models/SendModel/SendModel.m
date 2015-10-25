//
//  SendModel.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "SendModel.h"
#import <JDStatusBarNotification/JDStatusBarNotification.h>

#define AccessKey @"f1d90ca76830a3cb21ec3dc665ca13fc"

#define SecretKey @"8ad52f412abda2aa"

static SendModel *_model;

typedef void (^UploadPicBlock)(NSArray *picurl);
typedef void (^UploadVideoBlock)(NSArray *videourl);

@implementation SendModel


+(SendModel *)instance
{
    if (!_model) {
        _model = [SendModel new];
    }
    return _model;
}


-(void)sendPicText:(NSMutableDictionary *)data withPics:(NSArray *)pics
{
    
    
    if(![JDStatusBarNotification isVisible]) {
        [JDStatusBarNotification showWithStatus:@"Sending" styleName:@"JDStatusBarStyleWarning"];
    }
    [JDStatusBarNotification showActivityIndicator:YES
                                    indicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [self msgAPI:data withPics:pics];
    
//    NSString *code = data[@"code"];
//    NSString *fromphone = data[@"fromphone"];
//    NSString *tophone = data[@"tophone"];
//    
//    BmobQuery *bquery = [BmobQuery queryWithClassName:@"message"];
//    [bquery whereKey:@"code" equalTo:code];
//    [bquery whereKey:@"fromphone" equalTo:fromphone];
//    [bquery whereKey:@"tophone" equalTo:tophone];
//    
//    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        if (error){
//            //进行错误处理
//        }else{
//            if (array.count>0) {
//                
//                if (pics.count>0) {
//                    [self uploadFile:pics withBlock:^(NSArray *picurl) {
//                        BmobObject *result = array[0];
//                        [data setObject:picurl forKey:@"pics"];
//                        [result saveAllWithDictionary:data];
//                        [result updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//                            [self showSuccessOrFailure:isSuccessful error:error];
//                        }];
//                    }];
//                }else{
//                    BmobObject *result = array[0];
//                    [data setObject:[NSArray new] forKey:@"pics"];
//                    [result saveAllWithDictionary:data];
//                    [result updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//                       [self showSuccessOrFailure:isSuccessful error:error];
//                    }];
//
//                }
//                
//
//            }else{
//                
//                if (pics.count>0) {
//                    [self uploadFile:pics withBlock:^(NSArray *picurl) {
//                        
//                        BmobObject  *newBO = [BmobObject objectWithClassName:@"message"];
//                        [data setObject:picurl forKey:@"pics"];
//                        [newBO saveAllWithDictionary:data];
//                        [newBO saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//                            [self showSuccessOrFailure:isSuccessful error:error];
//                        }];
//                    }];
//                }else{
//                    BmobObject  *newBO = [BmobObject objectWithClassName:@"message"];
//                    [data setObject:[NSArray new] forKey:@"pics"];
//                    [newBO saveAllWithDictionary:data];
//                    [newBO saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//                        [self showSuccessOrFailure:isSuccessful error:error];
//                    }];
//                }
//                
//            }
//        }
//    }];
    
}

-(void)uploadFile:(NSArray *)pics withBlock:(UploadPicBlock)block
{
        [BmobProFile uploadFilesWithDatas:pics resultBlock:^(NSArray *filenameArray, NSArray *urlArray,NSArray *bmobFileArray, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
                [JDStatusBarNotification showWithStatus:@"Sending failure" dismissAfter:1 styleName:@"JDStatusBarStyleError"];
            } else {
                //路径数组和url数组（url数组里面的元素为NSString）
                NSMutableArray *newUrlArr = [NSMutableArray new];
                for (int i=0;i<filenameArray.count;i++) {
                    NSString *filename = filenameArray[i];
                    
                    NSString *url = urlArray[i];
                    NSString *str = [BmobProFile signUrlWithFilename:filename url:url validTime:1234567 accessKey:AccessKey secretKey:SecretKey];
                    
                    NSDictionary *pic = pics[i];
                    NSString *fileoldname = pic[@"filename"];
                    NSRange begin = [fileoldname rangeOfString:@"_"];
                    NSRange end = [fileoldname rangeOfString:@"."];
                    NSString *sizeStr = [fileoldname substringWithRange:NSMakeRange(begin.location+1,end.location-begin.location-1)];
                    
                    NSArray *sizeArr = [sizeStr componentsSeparatedByString:@"x"];
                    [newUrlArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:filename,@"name",sizeArr[0],@"width",sizeArr[1],@"height",str,@"pic", nil]];
                }
                block(newUrlArr);

            }
        } progress:^(NSUInteger index, CGFloat progress) {
            //index表示正在上传的文件其路径在数组当中的索引，progress表示该文件的上传进度
            NSLog(@"index %lu progress %f",(unsigned long)index,progress);
        }];
}

-(void)sendVideo:(NSMutableDictionary *)data withVideo:(NSData *)video withPic:(NSData *)pic
{
    
    if(![JDStatusBarNotification isVisible]) {
        [JDStatusBarNotification showWithStatus:@"Sending" styleName:@"JDStatusBarStyleWarning"];
    }
    [JDStatusBarNotification showActivityIndicator:YES
                                    indicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    
//    NSString *code = data[@"code"];
//    NSString *fromphone = data[@"fromphone"];
//    NSString *tophone = data[@"tophone"];
//    
//    BmobQuery *bquery = [BmobQuery queryWithClassName:@"message"];
//    [bquery whereKey:@"code" equalTo:code];
//    [bquery whereKey:@"fromphone" equalTo:fromphone];
//    [bquery whereKey:@"tophone" equalTo:tophone];
//    
//    NSDictionary *dic1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"video.mp4",@"filename",video,@"data",nil];
//    NSDictionary *dic2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"cover.jpg",@"filename",pic,@"data",nil];
//    
//    NSArray *dataArr = [NSArray arrayWithObjects:dic1,dic2,nil];
//    
//    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        if (error){
//            //进行错误处理
//        }else{
//            if (array.count>0) {
//                [self uploadVideo:dataArr withBlock:^(NSArray *videourl) {
//                    BmobObject *result = array[0];
//                    [data setObject:[NSArray new] forKey:@"pics"];
//                    for(NSString *str in videourl)
//                    {
//                        if ([str hasSuffix:@"mp4"]) {
//                            [data setObject:str forKey:@"video"];
//                        }else{
//                            [data setObject:str forKey:@"video_pic"];
//                        }
//                    }
//                    [result saveAllWithDictionary:data];
//                    [result updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//                        [self showSuccessOrFailure:isSuccessful error:error];
//                    }];
//                }];
//                
//            }else{
//                
//                [self uploadVideo:dataArr withBlock:^(NSArray *videourl) {
//                    BmobObject  *result = [BmobObject objectWithClassName:@"message"];
//                    [data setObject:[NSArray new] forKey:@"pics"];
//                    for(NSString *str in videourl)
//                    {
//                        if ([str hasSuffix:@"mp4"]) {
//                            [data setObject:str forKey:@"video"];
//                        }else{
//                            [data setObject:str forKey:@"video_pic"];
//                        }
//                    }
//                    [result saveAllWithDictionary:data];
//                    [result saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//                        [self showSuccessOrFailure:isSuccessful error:error];
//                    }];
//                }];
//                
//            }
//        }
//    }];

}

-(void)uploadVideo:(NSArray *)data withBlock:(UploadVideoBlock)block
{
    
    [BmobProFile uploadFilesWithDatas:data resultBlock:^(NSArray *filenameArray, NSArray *urlArray,NSArray *bmobFileArray, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            [JDStatusBarNotification showWithStatus:@"Sending failure" dismissAfter:1 styleName:@"JDStatusBarStyleError"];
        } else {
            //路径数组和url数组（url数组里面的元素为NSString）
            NSLog(@"fileArray %@ urlArray %@",filenameArray,urlArray);
            
            NSMutableArray *newUrlArr = [NSMutableArray new];
            for (int i=0;i<filenameArray.count;i++) {
                NSString *filename = filenameArray[i];
                
                if ([filename hasSuffix:@".jpg"]) {
                    
                    NSString *url = urlArray[i];
                    NSString *str = [BmobProFile signUrlWithFilename:filename url:url validTime:1234567 accessKey:AccessKey secretKey:SecretKey];
                    
                    [newUrlArr addObject:str];
                }else
                {
                    [newUrlArr addObject:filename];
                }
                
            }
            block(newUrlArr);
            
        }
    } progress:^(NSUInteger index, CGFloat progress) {
        //index表示正在上传的文件其路径在数组当中的索引，progress表示该文件的上传进度
        NSLog(@"index %lu progress %f",(unsigned long)index,progress);
    }];
}

-(void)showSuccessOrFailure:(BOOL) isSuccessful error:(NSError *) error
{
    if (isSuccessful) {
        //创建成功后的动作
        [JDStatusBarNotification showWithStatus:@"Sending success" dismissAfter:1 styleName:@"JDStatusBarStyleSuccess"];
    } else if (error){
        //发生错误后的动作
        NSLog(@"%@",error);
        [JDStatusBarNotification showWithStatus:@"Sending failure" dismissAfter:1 styleName:@"JDStatusBarStyleError"];
    } else {
        NSLog(@"Unknow error");
        [JDStatusBarNotification showWithStatus:@"Sending failure" dismissAfter:1 styleName:@"JDStatusBarStyleError"];
    }
}

#pragma mark API Request

-(void)msgAPI:(NSDictionary *)data withPics:(NSArray *)pics
{
    if (self.msgRequest) {
        [self.msgRequest cancel];
    }
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:data];
    
    BaseRequest * request =[[BaseRequest alloc]init];
    request.delegate =self;
    request.access = YES;
    request.agrs = dic;
    request.host = HOST;
    request.requestMethod = HTTP_POST_Request;
    request.actionKey =SEND_MSG;
    self.msgRequest = request;
    [request updateDatas:pics];
    
}

#pragma mark BaseRequestDelegate

- (void)request:(BaseRequest *)request successLoadData:(NSMutableDictionary *)dic
{

    [self showSuccessOrFailure:YES error:nil];
}

- (void)request:(BaseRequest *)request failedWithError:(NSString *)error
{
    [self showSuccessOrFailure:NO error:nil];
}



@end
