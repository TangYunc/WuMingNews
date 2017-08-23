//
//  AppDelegate.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "AppDelegate.h"
#import "RootTabBarController.h"
#import "LSLaunchAD.h"
//#import "SocialWKWebViewController.h"
#import "LoginViewController.h"
// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>
#import "webViewController.h"

@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor blackColor];
    [_window makeKeyAndVisible];
    
    //2.创建标签控制器
    RootTabBarController *rootTBC = [[RootTabBarController alloc] init];
    _window.rootViewController = rootTBC;
    
    [self JPUSHServiceInit:launchOptions];
    //向微信注册
    [WXApi registerApp:WX_App_ID];
    
    
    NSString *lanchPageUrl = [KUserDefault objectForKey:@"lanchPageUrl"];
    NSLog(@"lanchPageUrl:%@",lanchPageUrl);
    if (lanchPageUrl == nil || lanchPageUrl == Nil) {//第一次进入时候或者请求数据没有有效的 广告图片时显示默认图片
        [self loadingLaunchPageImageURL:nil withLocalAdImgName:@"lanchPageDefaultPictureName"];
    }else{//请求数据之后有有效的广告图时保存此广告图的地址，下次进入就显示此地址
        [self loadingLaunchPageImageURL:lanchPageUrl withLocalAdImgName:nil];
    }
    [self loadDatas];
//    [NSThread sleepForTimeInterval:3.0];//设置启动页面时间
    return YES;
}
// 极光推送初始化函数
-(void)JPUSHServiceInit:(NSDictionary *)launchOptions{

    // Required
    // notice: 3.0.0及以后版本注册可以这样写，也可以继续 旧的注册 式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加 定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
        
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }else{
        [JPUSHService registerForRemoteNotificationTypes: (UIUserNotificationTypeBadge |
                                                           UIUserNotificationTypeSound |
                                                           UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    // Optional
    // 获取IDFA
    // 如需使 IDFA功能请添加此代码并在初始化 法的advertisingIdentifier参数中填写对应值
    //    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册 法，改成可上报IDFA，如果没有使 IDFA直接传nil
    // 如需继续使 pushConfig.plist 件声明appKey等配置内容，请依旧使[JPUSHService setupWithOption:launchOptions] 式初始化。
    // 93cd45339ed56b036b13b1fb
    //1fea8a5f53cfff8ddc28d681
    
    [JPUSHService setupWithOption:launchOptions appKey:@"9e77f88c38b99fe45b84efcb"
                          channel:@"App Store"
                 apsForProduction:TRUE
            advertisingIdentifier:nil];
    if (launchOptions) {
        NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        //这个判断是在程序没有运行的情况下收到通知，点击通知跳转页面
        if (remoteNotification) {
            NSLog(@"推送消息=== %@",remoteNotification);
            [self goToMssageViewControllerWith:remoteNotification];
        }
    }
    
    // 2.1.9 版本后新增获取registration id block 接口
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID){
        if (resCode == 0) {
            NSLog(@"jpush registranton ok:%@", registrationID);
        }else{
            NSLog(@"jpush registranton err:%d", resCode) ;
        }
    }];
    
    [JPUSHService setLogOFF];
    
}
- (void)goToMssageViewControllerWith:(NSDictionary*)msgDic{
    
    
    NSLog(@"极光推送的通知内容:%@",msgDic);
    //将字段存入本地，因为要在你要跳转的页面用它来判断
    NSUserDefaults *pushJudge = [NSUserDefaults standardUserDefaults];
    [pushJudge setObject:@"push" forKey:@"push"];
    [pushJudge synchronize];
    NSString *titleStr = [msgDic objectForKey:@"title"];
    
    
    NSArray *allKeys = [msgDic allKeys];
    for (NSString *key in allKeys) {
        //将所有的key转换为全部小写
        NSString *lowerKey = [key lowercaseString];
        if ([lowerKey isEqualToString:@"url"]){
            //外链接
            NSString *wapUrl = [msgDic objectForKey:key];
            [self goToMarketCarouselWebViewControllerWapUrl:wapUrl withTitle:titleStr];
        }
    }
}
- (void)goToMarketCarouselWebViewControllerWapUrl:(NSString *)wap_url withTitle:(NSString *)title{
    
    webViewController *webVC = [[webViewController alloc] init];
    webVC.wap_url = wap_url;
    
    UINavigationController * Nav = [[UINavigationController alloc]initWithRootViewController:webVC];
    [self.window.rootViewController presentViewController:Nav animated:YES completion:nil];
}
//加载数据
- (void)loadDatas{
    // 1.请求参数
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseApi,lanchPage];
    
    // 发送请求
    [DataService postWithURL:url params:nil success:^(id responseObject) {
        
        NSString *lanchPageUrl = nil;
        NSLog(@"lanchPage=====%@",responseObject);
        if ([responseObject[@"code"] isEqualToString:@"200"]) {
            if (responseObject[@"succ"]) {
                //管理员上传了图片，并且图片使用（生效）
                lanchPageUrl = responseObject[@"url"];
                [KUserDefault setObject:lanchPageUrl forKey:@"lanchPageUrl"];
            }else{
                //管理员上传了图片，但是图片不生效
                lanchPageUrl = responseObject[@"url"];
                [KUserDefault setObject:nil forKey:@"lanchPageUrl"];
            }
            
        }else if ([responseObject[@"code"] isEqualToString:@"400"]){
            if (responseObject[@"succ"]) {
                //管理员并没有图片
                [KUserDefault setObject:nil forKey:@"lanchPageUrl"];
            }
        }
        [KUserDefault synchronize];
    } failure:^(NSError *error) {
    }];
}
- (void)loadingLaunchPageImageURL:(NSString *)imageURL withLocalAdImgName:(NSString *)localAdImgName{
//    __weak typeof(self) weakSelf = self;
    [LSLaunchAD showWithWindow:self.window
                     countTime:3
         showCountTimeOfButton:YES
                showSkipButton:YES
                isFullScreenAD:NO
                localAdImgName:localAdImgName
                      imageURL:imageURL
                    canClickAD:YES
                       aDBlock:^(BOOL clickAD) {
                           
                           if (clickAD) {
                               NSLog(@"点击了广告");
//                               SocialWKWebViewController *socialVC = [[SocialWKWebViewController alloc] init];
//                               [socialVC loadWebURLSring:@"https://www.baidu.com"];
//                               [weakSelf.window.rootViewController presentViewController:socialVC animated:YES completion:nil];
                           } else {
                               NSLog(@"完成倒计时或点击了跳转按钮");
                           }
                       }];

}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{

    return [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{

    return [WXApi handleOpenURL:url delegate:self];
}

- (void)onReq:(BaseReq *)req{

}
- (void)onResp:(BaseResp *)resp{

    // 向微信请求授权后,得到响应结果
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp *)resp;
        NSString *accessUrlStr = [NSString stringWithFormat:@"%@/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WX_BASE_URL, WX_App_ID, WX_App_Secret, temp.code];
        [DataService getWechatWithURL:accessUrlStr params:nil success:^(id responseObject) {
            NSLog(@"请求access的response = %@", responseObject);
            if (responseObject[@"errcode"] != nil){
                return;
            }
            NSDictionary *accessDict = [NSDictionary dictionaryWithDictionary:responseObject];
            NSString *accessToken = [accessDict objectForKey:WX_ACCESS_TOKEN];
            NSString *openID = [accessDict objectForKey:WX_OPEN_ID];
            NSString *refreshToken = [accessDict objectForKey:WX_REFRESH_TOKEN];
            // 本地持久化，以便access_token的使用、刷新或者持续
            if (accessToken && ![accessToken isEqualToString:@""] && openID && ![openID isEqualToString:@""]) {
                [KUserDefault setObject:accessToken forKey:WX_ACCESS_TOKEN];
                [KUserDefault setObject:openID forKey:WX_OPEN_ID];
                [KUserDefault setObject:refreshToken forKey:WX_REFRESH_TOKEN];
                [KUserDefault synchronize]; // 命令直接同步到文件里，来避免数据的丢失
            }
            [self wechatLoginByRequestForUserInfo];
        } failure:^(NSError *error) {
            NSLog(@"获取access_token时出错 = %@", error);
        }];
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]){
        switch (resp.errCode) {
            case WXSuccess:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"微信分享成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
                break;
            case WXErrCodeUserCancel:
                break;
            default:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失败" message:@"微信分享失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
                
                break;
        }    
    }

}
// 获取用户个人信息（UnionID机制）
- (void)wechatLoginByRequestForUserInfo {
    NSString *accessToken = [KUserDefault objectForKey:WX_ACCESS_TOKEN];
    NSString *openID = [KUserDefault objectForKey:WX_OPEN_ID];
    NSString *userUrlStr = [NSString stringWithFormat:@"%@/userinfo?access_token=%@&openid=%@", WX_BASE_URL, accessToken, openID];
    // 请求用户数据
    [DataService getWechatWithURL:userUrlStr params:nil success:^(id responseObject) {
        NSLog(@"请求用户信息的response = %@", responseObject);
         NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        [KUserDefault setObject:userDict[@"unionid"] forKey:unionid];
        [KUserDefault setObject:userDict[@"nickname"] forKey:nickname];
        [KUserDefault setObject:userDict[@"headimgurl"] forKey:headimgurl];
        [KUserDefault synchronize];
        [self wechatLoginWithOpenid:userDict];
    } failure:^(NSError *error) {
        NSLog(@"获取用户信息时出错 = %@", error);
    }];
    
}


-(void)wechatLoginWithOpenid:(NSDictionary *)rawData
{

    NSLog(@"headimgurl====%@",rawData[@"headimgurl"]);
    NSString *accessToken = [KUserDefault objectForKey:WX_ACCESS_TOKEN];
    NSString *auth_key = [DataService md5:@"121authkey"];
    // 1.请求参数
    NSMutableDictionary *tempPara = [NSMutableDictionary dictionary];
    [tempPara setObject:accessToken forKey:@"token"];
    [tempPara setObject:rawData[@"nickname"] forKey:@"nickname"];
    [tempPara setObject:rawData[@"headimgurl"] forKey:@"headimgurl"];
    [tempPara setObject:rawData[@"unionid"] forKey:@"unionid"];
    [tempPara setObject:auth_key forKey:@"auth_key"];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseApi,login_Api];
    
    // 发送请求
    [DataService postWithURL:url params:tempPara success:^(id responseObject) {
        NSLog(@"wechatLogin===%@",responseObject);
        [MBProgressHUD hideHUD];
        
        if (responseObject[@"succ"]) {
            
            // 0.显示状态栏
            UIApplication *app = [UIApplication sharedApplication];
            app.statusBarHidden = NO;
            
            [MBProgressHUD showSuccess:responseObject[@"msg"]];
//            [defaults setObject:responseObject[@"datas"][@"key"] forKey:userKey];
            [KUserDefault setObject:@1 forKey:IsLogin];
            [KUserDefault synchronize];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginResultNotification object:@"1"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fromPhoneVerifyCodeCtrlLoginSucc" object:nil];
            });
            
        }else {
            if (responseObject[@"datas"][@"msg"]) {
                [MBProgressHUD showError:responseObject[@"datas"][@"msg"]];
            }
            
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
    }];
}


#pragma mark- JPUSHRegisterDelegate
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    NSLog(@"deviceToken=====%@",deviceToken);
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidLoginNotification object:nil];
    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
    [self goToMssageViewControllerWith:userInfo];
    NSLog(@"收到通知ios6以下userInfo:%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"收到通知:%@",userInfo);
    [self goToMssageViewControllerWith:userInfo];
    
    if (application.applicationState != UIApplicationStateActive) {
        // 这里创建YSBTabBarController
        [[NSNotificationCenter defaultCenter] postNotificationName:@"appointmentCenter" object:nil];
        
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
    application.applicationIconBadgeNumber = 0;
}
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [self goToMssageViewControllerWith:userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"appointmentCenter" object:nil];
        });
    }
    completionHandler();  // 系统要求执行这个方法
}
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *currentContent = [NSString
                                stringWithFormat:
                                @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\n",
                                [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterNoStyle
                                                               timeStyle:NSDateFormatterMediumStyle],
                                title, content, extra];
    NSLog(@"%@", currentContent);
    
    NSString *allContent = [NSString
                            stringWithFormat:@"%@收到消息:\n%@\nextra:%@",
                            [NSDateFormatter
                             localizedStringFromDate:[NSDate date]
                             dateStyle:NSDateFormatterNoStyle
                             timeStyle:NSDateFormatterMediumStyle],
                            @"11",
                            extra];
    
    NSLog(@"allContent:%@" , allContent) ;
    //    [self reloadMessageCountLabel];
//    [JPUSHService setTags:nil aliasInbackground:[OpenUDID value]];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [JPUSHService setTags:nil alias:[OpenUDID value] fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias)
//         
//        {
//            
//        }];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];//清除角标
    [application cancelAllLocalNotifications];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
