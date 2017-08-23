//
//  LoginView.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/27.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "LoginView.h"
#import "UIButton+TYC.h"
#define kAlphaNum @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define ACCOUNT_MAX_CHARS 16

@interface LoginView ()<WXApiDelegate>

@property(nonatomic, copy) NSString *codeSmsStr;

@end
@implementation LoginView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.codeSmsStr = @"1111";
        
        //初始化UI
        [self initUI];

        // 监听键盘变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
        // 增加一个键盘监听方法（为了能够在键盘弹起完成后，让视图内容滚动）
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChanged) name:UIKeyboardDidChangeFrameNotification object:nil];
        //注册通知，收起键盘
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeTheKeyboard) name:@"closeTheKeyboard" object:nil];
        
    }
    return self;
}
//初始化UI
- (void)initUI{
    
    WS(weakSelf);
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:248/255.0 green:249/255.0 blue:250/255.0 alpha:1];
    [self addSubview:self.backgroundView];
    
    CGFloat theCornerRadius = 20;
    //accountView
    UIView *accountView = [[UIView alloc] init];
    accountView.layer.borderWidth = 1;
    accountView.layer.borderColor = UIColorFromRGBA(204, 204, 204, 1.0).CGColor;
    accountView.layer.cornerRadius = theCornerRadius;
    [self.backgroundView addSubview:accountView];
    
    self.errorPhoneNumLabel = [[UILabel alloc] init];
    self.errorPhoneNumLabel.font = [UIFont systemFontOfSize:10.f];
    self.errorPhoneNumLabel.textColor = UIColorFromRGBA(255, 85, 85, 1.0);
    self.errorPhoneNumLabel.textAlignment = NSTextAlignmentCenter;
    self.errorPhoneNumLabel.text = @"手机号错误";
    [self.backgroundView addSubview:self.errorPhoneNumLabel];
    self.errorPhoneNumLabel.hidden = YES;
    
    //VerificationCodeView
    UIView *verificationCodeView = [[UIView alloc] init];
    verificationCodeView.layer.borderWidth = 1;
    verificationCodeView.layer.borderColor = UIColorFromRGBA(204, 204, 204, 1.0).CGColor;
    verificationCodeView.layer.cornerRadius = theCornerRadius;
    [self.backgroundView addSubview:verificationCodeView];
    
    self.errorVerificationCodeLabel = [[UILabel alloc] init];
    self.errorVerificationCodeLabel.font = [UIFont systemFontOfSize:10.f];
    self.errorVerificationCodeLabel.textColor = UIColorFromRGBA(255, 85, 85, 1.0);
    self.errorVerificationCodeLabel.textAlignment = NSTextAlignmentCenter;
    self.errorVerificationCodeLabel.text = @"验证码错误";
    [self.backgroundView addSubview:self.errorVerificationCodeLabel];
    self.errorVerificationCodeLabel.hidden = YES;
    //确认按钮
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmBtn setTitle:@"登录" forState:UIControlStateNormal];
    self.confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self.confirmBtn setTitleColor:UIColorFromRGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:UIColorFromRGBA(255, 255, 255, 1.0) forState:UIControlStateDisabled];
    [self.confirmBtn setBackgroundImage:[self generateImageFromColor:UIColorFromRGBA(199, 9, 9, 1.0)] forState:UIControlStateNormal];
    [self.confirmBtn setBackgroundImage:[self generateImageFromColor:UIColorFromRGBA(250, 169, 169, 1)] forState:UIControlStateDisabled];
    [self.confirmBtn addTarget:self action:@selector(loginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmBtn.layer.cornerRadius = theCornerRadius;
    self.confirmBtn.clipsToBounds = YES;
    [self.backgroundView addSubview:self.confirmBtn];
    self.confirmBtn.enabled = NO;
    //tipsLabel
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.font = [UIFont systemFontOfSize:12.f];
    tipsLabel.textColor = UIColorFromRGBA(153, 153, 153, 1.0);
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = @"无需注册手机验证后自动登录";
    [self.backgroundView addSubview:tipsLabel];
    
    
    [accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerY.mas_equalTo(_firstView.mas_centerY);
        make.left.equalTo(weakSelf.backgroundView.mas_left).with.offset(31);
        make.right.equalTo(weakSelf.backgroundView.mas_right).with.offset(-30);
        make.top.equalTo(weakSelf.backgroundView.mas_top).with.offset(50);
        make.bottom.equalTo(weakSelf.errorPhoneNumLabel.mas_top).with.offset(-8);
        make.height.mas_equalTo(@44);
    }];
    
    [self.errorPhoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerY.mas_equalTo(_firstView.mas_centerY);
        make.left.equalTo(weakSelf.backgroundView.mas_left).with.offset(51);
        make.right.equalTo(weakSelf.backgroundView.mas_right).with.offset(-274);
        make.top.equalTo(accountView.mas_bottom).with.offset(8);
        make.bottom.equalTo(verificationCodeView.mas_top).with.offset(-8);
        make.height.mas_equalTo(@14);
    }];
    
    [verificationCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerY.mas_equalTo(_firstView.mas_centerY);
        make.left.equalTo(weakSelf.backgroundView.mas_left).with.offset(31);
        make.right.equalTo(weakSelf.backgroundView.mas_right).with.offset(-30);
        make.top.equalTo(weakSelf.errorPhoneNumLabel.mas_bottom).with.offset(8);
        make.bottom.equalTo(weakSelf.errorVerificationCodeLabel.mas_top).with.offset(-8);
        make.height.mas_equalTo(@44);
    }];
    [self.errorVerificationCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerY.mas_equalTo(_firstView.mas_centerY);
        make.left.equalTo(weakSelf.backgroundView.mas_left).with.offset(51);
        make.right.equalTo(weakSelf.backgroundView.mas_right).with.offset(-274);
        make.top.equalTo(verificationCodeView.mas_bottom).with.offset(8);
        make.bottom.equalTo(weakSelf.confirmBtn.mas_top).with.offset(-8);
        make.height.mas_equalTo(@14);
    }];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.backgroundView.mas_left).with.offset(32);
        make.right.equalTo(weakSelf.backgroundView.mas_right).with.offset(-29);
        make.top.equalTo(weakSelf.errorVerificationCodeLabel.mas_bottom).with.offset(8);
        make.bottom.equalTo(tipsLabel.mas_top).with.offset(-15);
        make.height.mas_equalTo(@44);
    }];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerY.mas_equalTo(_firstView.mas_centerY);
        make.left.equalTo(weakSelf.backgroundView.mas_left).with.offset(0);
        make.right.equalTo(weakSelf.backgroundView.mas_right).with.offset(0);
        make.top.equalTo(weakSelf.confirmBtn.mas_bottom).with.offset(15);
        make.height.mas_equalTo(@12);
    }];
    
    NSArray *placeholderArr = @[@"手机号",@"输入验证码"];
    self.accountTF = [[UITextField alloc] init];
    self.accountTF.placeholder = placeholderArr[0];
    self.accountTF.font = [UIFont systemFontOfSize:16.f];
    self.accountTF.borderStyle = UITextBorderStyleNone;
    self.accountTF.delegate = self;
    [accountView addSubview:self.accountTF];
    
    UIView *gapView = [[UIView alloc] init];
    gapView.backgroundColor = UIColorFromRGBA(204, 204, 204, 1.0);
    [accountView addSubview:gapView];
    
    self.obtainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.obtainBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [self.obtainBtn setTitleColor:UIColorFromRGBA(50, 50, 50, 1.0) forState:UIControlStateNormal];
    [self.obtainBtn setTitleColor:UIColorFromRGBA(153, 153, 153, 1.0) forState:UIControlStateDisabled];
    self.obtainBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [self.obtainBtn addTarget:self action:@selector(obtainBtn:) forControlEvents:UIControlEventTouchUpInside];
    [accountView addSubview:self.obtainBtn];
    
    [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(accountView.mas_centerY);
        make.left.equalTo(accountView.mas_left).with.offset(20);
        make.right.equalTo(gapView.mas_left).with.offset(0);
        make.height.mas_equalTo(@44);
    }];
    [gapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(accountView.mas_centerY);
        make.left.equalTo(weakSelf.accountTF.mas_right).with.offset(0);
        make.right.equalTo(gapView.mas_left).with.offset(-15);
        make.width.mas_equalTo(@1);
        make.height.mas_equalTo(@20);
    }];
    [self.obtainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(accountView.mas_centerY);
        make.left.equalTo(gapView.mas_right).with.offset(15);
        make.right.equalTo(accountView.mas_right).with.offset(-15);
        make.width.mas_equalTo(@80);
        make.height.mas_equalTo(@44);
    }];
    
    self.verificationCodeTF = [[UITextField alloc] init];
    self.verificationCodeTF.placeholder = placeholderArr[1];
    self.verificationCodeTF.font = [UIFont systemFontOfSize:16.f];
    self.verificationCodeTF.borderStyle = UITextBorderStyleNone;
    self.verificationCodeTF.delegate = self;
    [verificationCodeView addSubview:self.verificationCodeTF];
    [self.verificationCodeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(verificationCodeView.mas_centerY);
        make.left.equalTo(verificationCodeView.mas_left).with.offset(20);
        make.right.equalTo(verificationCodeView.mas_right).with.offset(-20);
        make.height.mas_equalTo(@44);
    }];
    
    self.wechatBtn = [[CustomWechatLoginItem alloc] initWithFrame:CGRectMake(0, 0, 80 * KWidth_ScaleW, 88 * KWidth_ScaleH)];
    [self.wechatBtn setTheLoginImageView:@"WeChatIcon"];
    [self.wechatBtn setTheLoginTitleLabel:@"微信登录"];
    [self.wechatBtn addTarget:self action:@selector(wechatLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:self.wechatBtn];
    self.wechatBtn.centerX = self.backgroundView.centerX;
    self.wechatBtn.bottom = self.backgroundView.bottom - 30 * KWidth_ScaleH;
}
#pragma mark -- 按钮事件
- (void)loginBtnAction:(UIButton *)button{
    
    NSLog(@"点击登录");
    //先将未到时间执行前的任务取消。
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(adressToDoSomething:) object:button];
    [self performSelector:@selector(adressToDoSomething:)withObject:button afterDelay:0.2f];
}
- (void)adressToDoSomething:(id)sender{
    
    [self endEditing:YES]; // 关闭键盘
    NSString *mobile = [self.accountTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *verificationCode =[self.verificationCodeTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //如果是11位的手机号码
    if ([self isMobileNum:mobile] == NO) {
        [MBProgressHUD showError:@"请确认您输入的是正确的手机号"];
        self.errorPhoneNumLabel.hidden = NO;
        return ;
    }
    self.errorPhoneNumLabel.hidden = YES;
    if (verificationCode.length != 4 || [verificationCode isEqualToString:@""]){
        
        //验证码需要4位数字
        self.verificationCodeTF.keyboardType = UIKeyboardTypeASCIICapable;
        self.verificationCodeTF.delegate  = self;
        [MBProgressHUD showError:@"请输入正确的验证码"];
        self.errorVerificationCodeLabel.hidden = NO;
        return;
    }else{
        if (![verificationCode isEqualToString:self.codeSmsStr]) {
            [MBProgressHUD showError:@"请输入正确的验证码"];
            self.errorVerificationCodeLabel.hidden = NO;
            return;
        }
    }
    self.errorVerificationCodeLabel.hidden = YES;
    
    [MBProgressHUD showMessage:@"正在帮你登录!"];
    
    // 1.请求参数
    NSMutableDictionary *tempPara = [NSMutableDictionary dictionary];
    [tempPara setObject:self.accountTF.text forKey:@"tel"];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseApi,verificationCodeLogin];
    
    // 发送请求
    [DataService postWithURL:url params:tempPara success:^(id responseObject) {
        NSLog(@"登录====%@",responseObject);
        [MBProgressHUD hideHUD];
        
        if (responseObject[@"succ"]) {
            
            [MBProgressHUD showSuccess:@"登录成功!"];
            
            [KUserDefault setObject:responseObject[@"data"][@"unionid"] forKey:unionid];
            [KUserDefault setObject:responseObject[@"data"][@"headimgurl"] forKey:headimgurl];
            [KUserDefault setObject:responseObject[@"data"][@"nickname"] forKey:nickname];

            [KUserDefault setObject:@1 forKey:IsLogin];
            [KUserDefault synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginResultNotification object:@"1"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fromPhoneVerifyCodeCtrlLoginSucc" object:nil];
            });
            
        }else {
            if (responseObject[@"msg"]) {
                [MBProgressHUD showError:responseObject[@"msg"]];
                return ;
            }
            
        }
        
    } failure:^(NSError *error) {
        self.obtainBtn.enabled = YES;
        self.errorPhoneNumLabel.hidden = YES;
        self.errorVerificationCodeLabel.hidden = YES;
        [MBProgressHUD showError:error.description];
    }];
    
}
- (void)obtainBtn:(UIButton *)button{
    
    NSLog(@"点击获取验证码");
    [self endEditing:YES]; // 关闭键盘
    NSString *mobile = [self.accountTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //如果是11位的手机号码
    if ([self isMobileNum:mobile] == NO) {
        [MBProgressHUD showError:@"请确认您输入的是正确的手机号"];
        self.errorPhoneNumLabel.hidden = NO;
        return ;
    }
    self.obtainBtn.enabled = NO;
    self.errorPhoneNumLabel.hidden = YES;
    // 1.请求参数
    NSString *token_key = [self getToken_key];
    NSMutableDictionary *tempPara = [NSMutableDictionary dictionary];
    [tempPara setObject:self.accountTF.text forKey:@"tel"];
    [tempPara setObject:token_key forKey:@"token_key"];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseApi,LoginSmscode];
    
    // 发送请求
    [DataService postWithURL:url params:tempPara success:^(id responseObject) {
        NSLog(@"验证码====%@",responseObject);
        
        if ([responseObject[@"info"] intValue] > 0) {
            
            [MBProgressHUD showSuccess:@"验证码已发送!"];
            self.codeSmsStr = responseObject[@"info"];
            [self.obtainBtn startWithTime:59 title:@"获取验证码" countDownTitle:@"s" mainColor:nil countColor:nil withObjectStr:nil];
            
        }else {
            if (responseObject[@"msg"]) {
                [MBProgressHUD showError:responseObject[@"msg"]];
            }
            [self.obtainBtn setTitleColor:UIColorFromRGBA(50, 50, 50, 1.0) forState:UIControlStateNormal];
            self.obtainBtn.enabled = YES;
            
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"获取验证码失败，请稍后重试!"];
        self.obtainBtn.enabled = YES;
        self.errorPhoneNumLabel.hidden = YES;
    }];

}
- (void)wechatLoginBtn:(UIButton *)button{
    
    //微信登录
    NSString *accessToken = [KUserDefault objectForKey:WX_ACCESS_TOKEN];
    NSString *openID = [KUserDefault objectForKey:WX_OPEN_ID];
    // 如果已经请求过微信授权登录，那么考虑用已经得到的access_token
    if (accessToken && openID) {
        
        NSString *refreshToken = [KUserDefault objectForKey:WX_REFRESH_TOKEN];
        NSString *refreshUrlStr = [NSString stringWithFormat:@"%@/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", WX_BASE_URL, WX_App_ID, refreshToken];
        [DataService getWechatWithURL:refreshUrlStr params:nil success:^(id responseObject) {
            NSLog(@"请求reAccess的response = %@", responseObject);
            NSDictionary *refreshDict = [NSDictionary dictionaryWithDictionary:responseObject];
            NSString *reAccessToken = [refreshDict objectForKey:WX_ACCESS_TOKEN];
            // 如果reAccessToken为空,说明reAccessToken也过期了,反之则没有过期
            if (reAccessToken) {
                // 更新access_token、refresh_token、open_id
                [KUserDefault setObject:reAccessToken forKey:WX_ACCESS_TOKEN];
                [KUserDefault setObject:[refreshDict objectForKey:WX_OPEN_ID] forKey:WX_OPEN_ID];
                [KUserDefault setObject:[refreshDict objectForKey:WX_REFRESH_TOKEN] forKey:WX_REFRESH_TOKEN];
                [KUserDefault synchronize];
                // 当存在reAccessToken不为空时直接执行AppDelegate中的wechatLoginByRequestForUserInfo方法
                !self.requestForUserInfoBlock ? : self.requestForUserInfoBlock();
            }
            else {
                [self wechatLogin];
            }
            
        } failure:^(NSError *error) {
            NSLog(@"用refresh_token来更新accessToken时出错 = %@", error);
        }];
    }
    else {
        [self wechatLogin];
    }

}



#pragma mark -- method
- (NSString *)getToken_key{

    NSString *phone = self.accountTF.text;
    NSString *key = @"wuming";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *otherStr = @"wxapp";
    NSString *tempStr = [NSString stringWithFormat:@"%@%@%@%@",key,dateString,phone,otherStr];
    NSString *token_key = [DataService md5:tempStr];
    return token_key;

}
- (void)wechatLogin {
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"WuMingApp";
    if ([WXApi isWXAppInstalled]) {
        [WXApi sendReq:req];
    }
    else {
        //没安装微信调用
        [WXApi sendAuthReq:req viewController:self.viewControler delegate:self];
//        [self setupAlertController];
    }
}
#pragma mark - 设置弹出提示语
- (void)setupAlertController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self.viewControler presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 根据颜色生成图片
- (UIImage *)generateImageFromColor:(UIColor *)color{
    
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorImage;
}



- (IBAction)textChanged:(id)sender {
    
    self.confirmBtn.enabled = YES;
    self.confirmBtn.enabled = (self.accountTF.text.length > 0
                               &&  self.verificationCodeTF.text.length > 0);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.accountTF)
    {
        [self.accountTF resignFirstResponder];
        [self.verificationCodeTF becomeFirstResponder];
        
    }else if (textField == self.verificationCodeTF)
    {
        [self.verificationCodeTF resignFirstResponder];
        [self.accountTF becomeFirstResponder];
    }
    return YES;
}
#pragma mark -- 通知
- (void)closeTheKeyboard{

    [self endEditing:YES];
    
}
#pragma 根据keyboardChanged滚动scrollView
-(void)keyboardChanged:(NSNotification *)notification {
    // UIKeyboardFrameEndUserInfoKey =>将要变化的大小
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardHeight = keyboardRect.size.height;
}

-(void)keyboardDidChanged
{
    [self scrollToBottom];
}


-(void)scrollToBottom
{
    Float32 keyboardMaxY = kScreenHeight - self.keyboardHeight;
    Float32 scrollOffset = self.inputViewMaxY - keyboardMaxY;
    if (scrollOffset >= 0) {
        [self setContentOffset:CGPointMake(0, scrollOffset) animated:YES];
    }
    
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.inputViewMaxY = CGRectGetMaxY(textField.superview.frame);
    [self scrollToBottom];
    return YES;
} 
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{

    NSLog(@"textField将要结束编辑:%@",textField.text);
    NSString *mobile = [self.accountTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *verificationCode =[self.verificationCodeTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (textField == self.accountTF) {
        //如果是11位的手机号码
        if ([self isMobileNum:mobile] == NO) {
            [MBProgressHUD showError:@"请确认您输入的是正确的手机号"];
            self.errorPhoneNumLabel.hidden = NO;
            self.obtainBtn.enabled = NO;
//            return NO;
        }else{
            self.obtainBtn.enabled = YES;
            self.errorPhoneNumLabel.hidden = YES;
        }
        
    }else if (textField == self.verificationCodeTF){
    
        if (verificationCode.length != 4 || [verificationCode isEqualToString:@""]){
            //验证码需要4位数字
            self.verificationCodeTF.keyboardType = UIKeyboardTypeASCIICapable;
            self.verificationCodeTF.delegate  = self;
            [MBProgressHUD showError:@"请输入正确的验证码"];
            self.errorVerificationCodeLabel.hidden = NO;
//            return NO;
        }else{
        
            self.errorVerificationCodeLabel.hidden = YES;
        }
    }
    if (mobile.length == 11 && verificationCode.length == 4) {
        self.confirmBtn.enabled = YES;
    }else{
        self.confirmBtn.enabled = NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string // return NO to not change text
{
    NSLog(@"textField输入:%@",textField.text);
    NSString *mobile = [self.accountTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *verificationCode =[self.verificationCodeTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (mobile.length == 11 && verificationCode.length == 4) {
        self.obtainBtn.enabled = YES;
        self.confirmBtn.enabled = YES;
    }else{
        self.confirmBtn.enabled = NO;
    }
    //判断是否超过 ACCOUNT_MAX_CHARS 个字符,注意要判断当string.leng>0
    //的情况才行，如果是删除的时候，string.length==0
    unsigned long length = textField.text.length;
    if (length >= ACCOUNT_MAX_CHARS && string.length >0)
    {
        return NO;
    }
    
    
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:kAlphaNum] invertedSet];
    NSString *filtered =
    [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basic = [string isEqualToString:filtered];
    return basic;
}
#pragma mark - 手机号码的有效性判断
#pragma 手机号判断2016.5
- (BOOL) isMobileNum:(NSString *)mobNum {
    //    电信号段:133/149/153/173/177/180/181/189
    //    联通号段:130/131/132/145/155/156/171/175/176/185/186
    //    移动号段:134/135/136/137/138/139/147/150/151/152/157/158/159/178/182/183/184/187/188
    //    虚拟运营商:170
    
    NSString *MOBILE = @"^1(3[0-9]|4[579]|5[0-35-9]|7[0135-8]|8[0-9])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    return [regextestmobile evaluateWithObject:mobNum];
}

// 删除通知
-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
