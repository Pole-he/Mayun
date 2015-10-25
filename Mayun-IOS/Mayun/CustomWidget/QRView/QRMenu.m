//
//  QRMenu.m
//  QRWeiXinDemo
//
//  Created by lovelydd on 15/4/30.
//  Copyright (c) 2015年 lovelydd. All rights reserved.
//

#import "QRMenu.h"

@implementation QRMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
     
        //[self setupQRItem];
        
        [self styple];
        
    }
    
    return self;
}

-(void) styple {
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    [self addSubview:lable];
    lable.text = @"place in the scanning frame,automatically scan code";
    lable.textColor = [UIColor whiteColor];
    lable.font = [UIFont systemFontOfSize:13.0f];
    lable.textAlignment = NSTextAlignmentCenter;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(quxia) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    button.frame = CGRectMake(ScreenWidth/2-70, 40, 140, 40);
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    button.layer.cornerRadius = button.frame.size.height/2;
    button.layer.masksToBounds = YES;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}


-(void) quxia {
    
    [[ToolClass viewController:self].navigationController popViewControllerAnimated:YES];
}
- (void)setupQRItem {
    
    QRItem *qrItem = [[QRItem alloc] initWithFrame:(CGRect){
        .origin.x = 0,
        .origin.y = 0,
        .size.width = self.bounds.size.width / 2,
        .size.height = self.bounds.size.height
    } titile:@"二维码扫描"];
    qrItem.type = QRItemTypeQRCode;
    [self addSubview:qrItem];
    
    QRItem *otherItem = [[QRItem alloc] initWithFrame: (CGRect){
        
        .origin.x = self.bounds.size.width / 2,
        .origin.y = 0,
        .size.width = self.bounds.size.width / 2,
        .size.height = self.bounds.size.height
    } titile:@"条形码扫描"];
    otherItem.type = QRItemTypeOther;
    [self addSubview:otherItem];
    
    [qrItem addTarget:self action:@selector(qrScan:) forControlEvents:UIControlEventTouchUpInside];
    [otherItem addTarget:self action:@selector(qrScan:) forControlEvents:UIControlEventTouchUpInside];
    
}


#pragma mark - Action

- (void)qrScan:(QRItem *)qrItem {
    
    if (self.didSelectedBlock) {
        
        self.didSelectedBlock(qrItem);
    }
}



@end
