//
//  BaseVC.m
//  Care
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()
{
    UILabel *_titleLable;
    UIButton *_rightBtn;
    UIButton *_leftBtn;
}

@end

@implementation BaseVC

- (void)viewDidLoad {
    UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    bg.image = [UIImage imageNamed:@"general_bg"];
    [self.view insertSubview:bg atIndex:0];
    [super viewDidLoad];
    [self createView];
}


- (void)createView {
    
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    UILabel *lable = [[UILabel alloc]init];
    lable.center = CGPointMake(ScreenWidth/2, 42);
    lable.layer.bounds = CGRectMake(0, 0, 200, 40);
    lable.text = @"";
    lable.font = [UIFont systemFontOfSize:18.0f];
    lable.textColor = [UIColor whiteColor];
    lable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lable];
    
    _titleLable = lable;
    
    
    //by box
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(0, 25, 40, 35);
    [_leftBtn addTarget:self action:@selector(leftSelectedEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_leftBtn];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(ScreenWidth - 50, 26, 60, 35);
    [_rightBtn addTarget:self action:@selector(rightSelectedEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rightBtn];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 63, ScreenWidth,Line_Width)];
    line.backgroundColor = UIColorFromRGB(0xffffff, 0.5);
    [self.view addSubview:line];
    
}

- (void)leftSelectedEvent:(id)sender {
    
}

- (void)rightSelectedEvent:(id)sender {
    
}

#pragma mark ---- 10.10扩展

-(void)setBaseBackWith:(NSString *)titleName
{
    if (titleName.length != 0) {
        _titleLable.text = titleName;
    }
    [_leftBtn setImage:[UIImage imageNamed:@"general_back_icon"]  forState:UIControlStateNormal];
}

-(void)setBaseBackWith:(NSString *)titleName right:(NSString *)nameRight
{
    if (titleName.length != 0) {
        _titleLable.text = titleName;
    }
    [_leftBtn setImage:[UIImage imageNamed:@"general_back_icon"]  forState:UIControlStateNormal];
    if (nameRight) {
        BOOL isPng = [nameRight hasSuffix:@"png"];
        if (isPng) {
            [_rightBtn setImage:[UIImage imageNamed:nameRight] forState:UIControlStateNormal];
        }else{
            [_rightBtn setTitle:nameRight forState:UIControlStateNormal];
            [_rightBtn setTitleColor:[UIColor whiteColor] forState:normal];
            _rightBtn.frame = CGRectMake(ScreenWidth-50, 26, 35, 35);
            [_rightBtn sizeToFit];
            _rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        }
    }else{
        _rightBtn.hidden = YES;
    }
}

- (void)setBaseVCAttributesWith:(NSString *)titleName left:(NSString *)nameLeft right:(NSString *)nameRight {
    
    if (titleName.length != 0) {
        _titleLable.text = titleName;
    }
    
    if (nameLeft) {
        BOOL isPng = [nameLeft hasSuffix:@"png"];
        if (isPng) {
            [_leftBtn setImage:[UIImage imageNamed:nameLeft] forState:UIControlStateNormal];
        }else{
            [_leftBtn setTitle:nameLeft forState:UIControlStateNormal];
            [_leftBtn setTitleColor:[UIColor whiteColor] forState:normal];
            _leftBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        }
    }else{
        _leftBtn.hidden = YES;
    }
    
    if (nameRight) {
        BOOL isPng = [nameRight hasSuffix:@"png"];
        if (isPng) {
            [_rightBtn setImage:[UIImage imageNamed:nameRight] forState:UIControlStateNormal];
        }else{
            [_rightBtn setTitle:nameRight forState:UIControlStateNormal];
            [_rightBtn setTitleColor:[UIColor whiteColor] forState:normal];
            _rightBtn.frame = CGRectMake(ScreenWidth-50, 26, 35, 35);
            _rightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        }
    }else{
        _rightBtn.hidden = YES;
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
