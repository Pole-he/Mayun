//
//  LoginVC.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "LoginVC.h"

#import "VWWWaterView.h"
#import "DKCircleButton.h"
#import "QQLogin.h"
#import "MainVC.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "PhoneVC.h"


@interface LoginVC ()<LoginDelegate,UIViewControllerTransitioningDelegate,BaseRequestDelegate>

@property(nonatomic,strong) BaseRequest *loginRequest;
@property(nonatomic,strong) NSDictionary *qqinfo;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *img = [UIImage imageNamed:@"login_qq_bg"];
    
    UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, img.size.height*ScreenWidth/img.size.width)];
    view.image = img;
    [self.view addSubview:view];
    
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_bg"] forState:UIControlStateNormal];
    [loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn sizeToFit];
    loginBtn.center = CGPointMake(ScreenWidth/2, ScreenHeight/2+50);
    
    [self.view addSubview:loginBtn];
    
    [loginBtn addTarget:self action:@selector(tapOnButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tapOnButton {
    QQLogin *login = [QQLogin getinstance];
    login.delegate = self;
    [login loginQQ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)successLogin:(NSDictionary *)user
{
    self.qqinfo = user;
    
    [self loginAPI:user[@"accessToken"]];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingAnimator new];
}

- (void)present:(id)sender
{
    PhoneVC *modalViewController = [PhoneVC new];
    modalViewController.transitioningDelegate = self;
    modalViewController.user = sender;
    modalViewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:modalViewController
                       animated:YES
                     completion:NULL];
}



#pragma mark API Request

-(void)loginAPI:(NSString *)access_token
{
    if (self.loginRequest) {
        [self.loginRequest cancel];
    }
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setObject:access_token forKey:@"token"];
    
    BaseRequest * request =[[BaseRequest alloc]init];
    request.delegate =self;
    request.agrs = dic;
    request.host = HOST;
    request.requestMethod = HTTP_POST_Request;
    request.actionKey =LOGIN;
    self.loginRequest = request;
    [request start];
    
}

#pragma mark BaseRequestDelegate

- (void)request:(BaseRequest *)request successLoadData:(NSMutableDictionary *)dic
{

    NSInteger isExist = [dic[@"isExist"] integerValue];
    
    if (isExist == 0) {
        [self performSelector:@selector(present:) withObject:self.qqinfo afterDelay:0.1f];
    }else{
        
        
         [ToolClass saveUserInfo:dic[@"user"]];
         MainVC *vc = [MainVC new];
         UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
         vc.navigationController.navigationBarHidden = YES;
         [self presentViewController:nav animated:YES completion:nil];
    }
    
    
}

- (void)request:(BaseRequest *)request failedWithError:(NSString *)error
{

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
