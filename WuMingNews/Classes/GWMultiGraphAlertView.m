//
//  GWMultiGraphAlertView.m
//  cps
//
//  Created by Mr_Tang on 2016/12/13.
//  Copyright © 2016年 com.guwu. All rights reserved.
//

#import "GWMultiGraphAlertView.h"
#import "LoginViewController.h"

@interface GWMultiGraphAlertView ()<WXApiDelegate>

@property(nonatomic,strong)UIView *bjView;
@property(nonatomic,strong)UIView *maskView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIButton *wechatLoginBtn;
@property(nonatomic,strong)UIButton *phoneLoginBtn;
@end

@implementation GWMultiGraphAlertView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addSubview:self.maskView];
        [self addSubview:self.bjView];
    }
    return self;
}
-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.4;
    }
    return _maskView;
}

//2.创建一个弹窗视图
-(UIView *)bjView
{
    if (!_bjView) {
        //1.
        _bjView = [[UIView alloc] init];
        _bjView.backgroundColor = UIColorFromRGBA(255, 255, 255, 1.0);
        _bjView.clipsToBounds = YES;
        _bjView.layer.borderWidth = 0.5;
        _bjView.layer.cornerRadius = 10 * KWidth_ScaleW;
        _bjView.width = 220 * KWidth_ScaleW;
        _bjView.height = 260 * KWidth_ScaleH;
        _bjView.centerX = _maskView.centerX;
        _bjView.centerY = _maskView.centerY;
        
        UIImageView *cancelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 16 * KWidth_ScaleH, 16 * KWidth_ScaleW, 16 * KWidth_ScaleH)];
        cancelImageView.image = [UIImage imageNamed:@"cancelImageIcon"];
        [_bjView addSubview:cancelImageView];
        cancelImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *cancelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTapAction:)];
        [cancelImageView addGestureRecognizer:cancelTap];
        cancelImageView.right = _bjView.width - 16 * KWidth_ScaleW;
        //2.
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 39 * KWidth_ScaleH, _bjView.width, 16 * KWidth_ScaleH)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        titleLabel.textColor = UIColorFromRGBA(50, 50, 50, 1.0);
        titleLabel.text = @"一键登录你的头条";
        [_bjView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        CGFloat btnWidth = _bjView.width - (30 * KWidth_ScaleW) * 2;
        //3.
        UIImageView *weChatLoginImageView = [[UIImageView alloc] initWithFrame:CGRectMake((30 * KWidth_ScaleW), titleLabel.bottom + 40 * KWidth_ScaleH, btnWidth, 40 * KWidth_ScaleH)];
        weChatLoginImageView.image = [UIImage imageNamed:@"MultiGraphAlertWechatLoginIcon"];
        [_bjView addSubview:weChatLoginImageView];
        weChatLoginImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *weChatImageViewLoginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weChatImageViewLoginTapAction:)];
        [weChatLoginImageView addGestureRecognizer:weChatImageViewLoginTap];
        
        //4.
        UIImageView *phoneLoginImageView = [[UIImageView alloc] initWithFrame:CGRectMake((30 * KWidth_ScaleW), weChatLoginImageView.bottom + 30 * KWidth_ScaleH, btnWidth, 40 * KWidth_ScaleH)];
        phoneLoginImageView.image = [UIImage imageNamed:@"MultiGraphAlertPhoneLoginIcon"];
        [_bjView addSubview:phoneLoginImageView];
        phoneLoginImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *phoneLoginImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneLoginImageViewTapAction:)];
        [phoneLoginImageView addGestureRecognizer:phoneLoginImageViewTap];

    }
    return _bjView;
}

//取消点击事件
- (void)cancelTapAction:(UITapGestureRecognizer *)tap
{
    NSLog(@"取消");
    [self removeFromSuperview];
}
- (void)weChatImageViewLoginTapAction:(UITapGestureRecognizer *)tap{

    NSLog(@"点击微信登录");
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
- (void)phoneLoginImageViewTapAction:(UITapGestureRecognizer *)tap{

    NSLog(@"点击手机登录");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickPhoneLoginBtn" object:nil];
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.alertVC.navigationController pushViewController:loginVC animated:YES];
    [self removeFromSuperview];
}
- (void)wechatLogin {
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"GSTDoctorApp";
    if ([WXApi isWXAppInstalled]) {
        [WXApi sendReq:req];
    }
    else {
        //没安装微信调用
        [WXApi sendAuthReq:req viewController:self.alertVC delegate:self];
//        [self setupAlertController];
    }
    [self removeFromSuperview];
}
#pragma mark - 设置弹出提示语
- (void)setupAlertController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self.alertVC presentViewController:alert animated:YES completion:nil];
}

@end
