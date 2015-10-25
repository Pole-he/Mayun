//
//  PhoneVC.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "PhoneVC.h"
#import "UIColor+CustomColors.h"
#import "MainVC.h"
@interface PhoneVC ()<BaseRequestDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIButton *goBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property(nonatomic,strong) BaseRequest *codeRequest;
@property(nonatomic,strong) BaseRequest *registerRequest;

@end

@implementation PhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.cornerRadius = 8.f;
}

#pragma mark - Private Instance methods

- (IBAction)dimiss:(id)sender {
        [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)getCode:(id)sender {
    
    if (![ToolClass validateMobile:self.phoneTF.text]) {
        return;
    }
     [self.codeBtn setEnabled:NO];
    __block int timeout = 59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.codeBtn setEnabled:YES];
                [self.codeBtn setTitle:@"Get Code" forState:UIControlStateNormal];
            });
        }else{
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.codeBtn setTitle:strTime forState:UIControlStateDisabled];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);

    [self codeAPI];
}

- (IBAction)goAction:(id)sender {
    
    [self registerAPI];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark API Request

-(void)codeAPI
{
    if (self.codeRequest) {
        [self.codeRequest cancel];
    }
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.phoneTF.text forKey:@"mobile"];
    
    BaseRequest * request =[[BaseRequest alloc]init];
    request.delegate =self;
    request.agrs = dic;
    request.host = HOST;
    request.requestMethod = HTTP_POST_Request;
    request.actionKey =SEND_CODE;
    self.codeRequest = request;
    [request start];
    
}

-(void)registerAPI
{
    if (self.registerRequest) {
        [self.registerRequest cancel];
    }
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];

    
    [dic setObject:self.user[@"nickname"] forKey:@"username"];
    [dic setObject:self.user[@"figureurl_2"] forKey:@"avatar"];
    [dic setObject:self.phoneTF.text forKey:@"mobile"];
    [dic setObject:self.user[@"accessToken"] forKey:@"token"];
    [dic setObject:self.codeTF.text forKey:@"code"];
    
    BaseRequest * request =[[BaseRequest alloc]init];
    request.delegate =self;
    request.agrs = dic;
    request.host = HOST;
    request.requestMethod = HTTP_POST_Request;
    request.actionKey =REGSTER;
    self.registerRequest = request;
    [request start];
    
}

#pragma mark BaseRequestDelegate

- (void)request:(BaseRequest *)request successLoadData:(NSMutableDictionary *)dic
{

    if (request == self.registerRequest) {
        NSMutableDictionary *user = [NSMutableDictionary new];
        
        [user setObject:self.user[@"figureurl_2"] forKey:@"avatar"];
        [user setObject:self.user[@"accessToken"] forKey:@"token"];
        [user setObject:self.user[@"nickname"] forKey:@"username"];
        [user setObject:self.phoneTF.text forKey:@"mobile"];
        
        [ToolClass saveUserInfo:user];
        
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
