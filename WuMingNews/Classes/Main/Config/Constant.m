//
//  Constant.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/3.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

// 正式环境
//NSString *const BaseApi = @"http://weixin.121mai.com/";
// 预生产
//NSString *const BaseApi = @"http://weixin.121weixin.com";
//// 测试机
NSString *const BaseApi = @"http://testwx.121mai.com";

//***************************启动页相关************************//
NSString *const lanchPage = @"/index.php?g=App&m=Wxapi&a=start_pic&key=wuming";

//***************************新闻相关************************//
NSString *const newsWuming = @"/index.php?g=App&m=Wxapi&a=index&key=wuming";


//***************************本地生活************************//
NSString *const localLifeWuming = @"/index.php?g=App&m=Wxapi&a=local&key=wuming";

//*****************************我的与登录相关**************************//
NSString *const get_UserInfo_Api = @"/index.php?g=App&m=Userinfo&a=get_UserInfo_Api";
NSString *const login_Api = @"/index.php?g=App&m=Userinfo&a=login_Api";

NSString *const verificationCodeLogin = @"/index.php?g=App&m=Wxapi&a=get_tel_wxuser&";
NSString *const LoginSmscode = @"/index.php?g=App&m=Wxapi&a=get_code";

//***************************收藏页面 && 关于我们************************//
NSString *const collectionAndAboutUs = @"/index.php?g=App&m=Wxapi&a=my&key=wuming";

//*****************通知字符串定义***********************//
NSString *const LoginResultNotification = @"LoginResultNotification";
NSString *const VerificationCodeTime = @"VerificationCodeTime";

NSString *const networkStatus = @"networkStatus";
NSString *const userKey = @"userKey";
NSString *const unionid = @"unionid";
NSString *const IsLogin = @"IsLogin";
NSString *const headimgurl = @"headimgurl";
NSString *const nickname = @"nickname";


