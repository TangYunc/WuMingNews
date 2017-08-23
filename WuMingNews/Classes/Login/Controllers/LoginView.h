//
//  LoginView.h
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/27.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomWechatLoginItem.h"

@interface LoginView : UIScrollView<UITextFieldDelegate>

@property (strong, nonatomic) UIView *backgroundView;
@property (nonatomic, assign) Float32 keyboardHeight;
@property (nonatomic, assign) Float32 inputViewMaxY;

@property (strong, nonatomic) UITextField *accountTF;
@property (strong, nonatomic) UITextField *verificationCodeTF;

@property (strong, nonatomic) UILabel *errorPhoneNumLabel;
@property (strong, nonatomic) UILabel *errorVerificationCodeLabel;

@property (strong, nonatomic) UIButton *confirmBtn;
@property (strong, nonatomic) UIButton *obtainBtn;
@property (strong, nonatomic) CustomWechatLoginItem *wechatBtn;

/** 通过block去执行AppDelegate中的wechatLoginByRequestForUserInfo方法 */
@property (copy, nonatomic) void (^requestForUserInfoBlock)();
@end
