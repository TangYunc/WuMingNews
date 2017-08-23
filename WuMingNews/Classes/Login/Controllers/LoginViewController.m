//
//  LoginViewController.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/27.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginView.h"

@interface LoginViewController ()


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavItemSubViews];
    [self initUI];
    //注册通知监听登录状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucc:) name:@"fromPhoneVerifyCodeCtrlLoginSucc" object:nil];
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    UIApplication *app = [UIApplication sharedApplication];
    app.statusBarStyle = UIStatusBarStyleLightContent;
    UIImage *theImage = [self generateImageFromColor:UIColorFromRGBA(199, 9, 9, 1.0)];
    [self.navigationController.navigationBar setBackgroundImage:theImage forBarMetrics:UIBarMetricsDefault];
    
    
}
- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    //发送通知，收起键盘
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeTheKeyboard" object:nil];
    
}
- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.loginView = nil;
    [self.loginView removeFromSuperview];
    self.view = nil;
    
}
//初始化导航栏元素
- (void)initNavItemSubViews{

    // 自定义标题视图
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16.f];
    titleLabel.text = @"登陆武鸣头条";
    self.navigationItem.titleView = titleLabel;
    
    // 左侧按钮
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 40);
    [leftButton setImage:[UIImage imageNamed:@"loginBlackBackBtn"] forState:UIControlStateNormal];
    // 添加事件
    [leftButton addTarget:self action:@selector(loginBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;
}
- (void)initUI{
    
    self.loginView = [[LoginView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    [self.view addSubview:self.loginView];
}
#pragma mark -- 按钮事件
- (void)loginBackButtonAction:(UIButton *)button{
    
    //返回按钮事件
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 通知
- (void)loginSucc:(NSNotification *)notify{

    [self.navigationController popViewControllerAnimated:YES];
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
