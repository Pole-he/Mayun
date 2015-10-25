//
//  EditorPicVC.m
//  Mayun
//
//  Created by Nathan_he on 15/10/24.
//  Copyright (c) 2015年 Nathan_he. All rights reserved.
//

#import "EditorPicVC.h"
#import "NaAddImage.h"
#import "UITextView+Placeholder.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SendModel.h"
#import "JDStatusBarNotification.h"
#import <ContactsUI/ContactsUI.h>
#import "NSString+Emoji.h"

@interface EditorPicVC ()<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *bgText;
@property (weak, nonatomic) IBOutlet UITextView *contentTV;
@property (weak, nonatomic) IBOutlet NaAddImage *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgesHeight;
@property (weak, nonatomic) IBOutlet UIView *toView;
@property (weak, nonatomic) IBOutlet UILabel *toLB;

@property (nonatomic,strong) NSString *toName;
@property (nonatomic,strong) NSString *toPhone;

@end

@implementation EditorPicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBaseBackWith:@"" right:@"Send"];
    
    [self.imageView setHeightBlock:^{
        self.imgesHeight.constant = CGRectGetHeight(self.imageView.frame);
    }];
    
    
    [self.imageView addArrImage:self.imgs];
    
    self.contentTV.placeholder = @"这一刻的想法";
    self.contentTV.placeholderColor = UIColorFromRGB(0xf0f0f0, 1.0); // optional
    
    UITapGestureRecognizer *toTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toAddressBook:)];
    [self.toView addGestureRecognizer:toTap];
    
}

- (void)leftSelectedEvent:(id)sender {
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightSelectedEvent:(id)sender
{
    if (self.imageView.images.count==0 && [self.contentTV.text isEqualToString:@""])
    {
        [JDStatusBarNotification showWithStatus:@"Please input something" dismissAfter:1.0f styleName:@"JDStatusBarStyleError"];
        return;
    }
    
    if (self.toName==nil || self.toPhone==nil)
    {
        [JDStatusBarNotification showWithStatus:@"Please input \"To\"" dismissAfter:1.0f styleName:@"JDStatusBarStyleError"];
        return;
    }
    
    
    NSMutableArray *pics = [NSMutableArray array];
    
    for (UIImage *img in self.imageView.images) {
        NSData *imageData=UIImageJPEGRepresentation(img,0.8f);
        NSString *photoName=[NSString stringWithFormat:@"%@_%dx%d.jpg",[[NSUUID UUID] UUIDString],(int)img.size.width,(int)img.size.height];
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:photoName,@"filename",imageData,@"data",nil];
        
        [pics addObject:dic];
    }
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    
    NSDictionary *user = [ToolClass userInfo];
    
    [data setObject:self.code forKey:@"codeUrl"];
    [data setObject:self.toPhone forKey:@"toMobile"];
    [data setObject:self.toName forKey:@"toUsername"];
    //[data setObject:[self.contentTV.text encodeEmoji] forKey:@"content"];
    [data setObject:self.contentTV.text  forKey:@"content"];
    [[SendModel instance] sendPicText:data withPics:pics];
    //关闭发送
    [self leftSelectedEvent:nil];
}

-(void)toAddressBook:(UITapGestureRecognizer *)tap
{
    
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=9.0) {
        CNContactPickerViewController*contactVC = [[CNContactPickerViewController alloc] init];
        contactVC.delegate = self;
        [self presentViewController:contactVC animated:YES completion:nil];
    }else{
        ABPeoplePickerNavigationController *peoleVC = [[ABPeoplePickerNavigationController alloc] init];
        peoleVC.peoplePickerDelegate = self;
        
        [self presentViewController:peoleVC animated:YES completion:nil];
        
        if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
            peoleVC.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        //        pNC.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    
    //获取联系人姓名
    NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@", phoneNO);
    if (phone && phoneNO.length == 11) {
        
        self.toPhone = phoneNO;
        
        self.toName = name;
        
        self.toLB.text = [NSString stringWithFormat:@"To: %@ %@",name,phoneNO];
        
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
        return;
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"请选择正确手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person NS_AVAILABLE_IOS(8_0)
{
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    personViewController.displayedPerson = person;
    
    [peoplePicker pushViewController:personViewController animated:YES];
    
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}



- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person NS_DEPRECATED_IOS(2_0, 8_0)
{
    return YES;
}



- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier NS_DEPRECATED_IOS(2_0, 8_0)
{
    
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    
    //获取联系人姓名
    NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@", phoneNO);
    
    if (phone && phoneNO.length == 11) {
        
        self.toPhone = phoneNO;
        
        self.toName = name;
        
        self.toLB.text = [NSString stringWithFormat:@"To: %@ %@",name,phoneNO];
        
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"请选择正确手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    return NO;
}



#pragma mark CNContactPickerDelegate

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
//{
//    NSString *name = [NSString stringWithFormat:@"姓名:%@ %@ %@",contact.givenName,contact.familyName,contact.nameSuffix];
//
//    NSLog(@"name = %@",name);
//
//    for (CNLabeledValue *lv in contact.phoneNumbers) {
//
//        CNPhoneNumber *pNum = lv.value;
//
//
//        NSString *phoneNum = [NSString stringWithFormat:@"\t%@\n",pNum.stringValue];
//
//        NSLog(@"phoneNum = %@",phoneNum);
//    }
//}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    
    //获取联系人姓名
    NSString *name = [NSString stringWithFormat:@"%@%@",contactProperty.contact.familyName,contactProperty.contact.givenName];
    
    CNPhoneNumber *pNum = contactProperty.value;
    
    NSString *phoneNO = pNum.stringValue;
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (phoneNO.length == 11) {
        
        self.toPhone = phoneNO;
        
        self.toName = name;
        
        self.toLB.text = [NSString stringWithFormat:@"To: %@ %@",name,phoneNO];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"请选择正确手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
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
