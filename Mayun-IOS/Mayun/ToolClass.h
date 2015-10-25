

#import <Foundation/Foundation.h>

@interface ToolClass : NSObject 

//根据View 获取VC
+ (UIViewController*)viewController:(UIView *)view;
//判断手机正则
+ (BOOL) validateMobile:(NSString *)mobile;

+ (void)saveUserInfo:(NSDictionary *)user;

+ (NSDictionary *) userInfo;

+(NSString *) getMyPhone;

//获取用户信息
+(NSString *) userId;

//对长文本进行有效排版
+ (NSMutableAttributedString *)getAttrString:(NSString *)string;

@end
