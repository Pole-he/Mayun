//
//  main.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright © 2015年 Nathan_he. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <BmobSDK/Bmob.h>
int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSString *appKey = @"b1a08d5100e28677c9cd784425829c25";
        [Bmob registerWithAppKey:appKey];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
