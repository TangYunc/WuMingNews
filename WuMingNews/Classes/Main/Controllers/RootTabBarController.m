//
//  RootTabBarController.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "RootTabBarController.h"
#import "NewsViewController.h"
#import "LocalLifeViewController.h"
#import "MineViewController.h"
#import "BaseNavigationController.h"
#import "CustomBarButton.h"
#import "CustomTabBar.h"

@interface RootTabBarController ()<CustomTabBarDelegate>

@property(nonatomic, weak)CustomTabBar *customTabBar;

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CustomTabBar *customTabBar = [[CustomTabBar alloc] init];
    customTabBar.frame = self.tabBar.bounds;
    [self.tabBar addSubview:customTabBar];
    self.customTabBar = customTabBar;
    
    self.customTabBar.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToAppointmentCenter) name:@"appointmentCenter" object:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (UIView *subView in self.tabBar.subviews) {
        if ([subView isKindOfClass:[UIControl class]]) {
            [subView removeFromSuperview];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"self======%@",self);
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [child removeFromSuperview];
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //01 新闻
        NewsViewController *newsVC = [[NewsViewController alloc] init];
        [self addOneChildViewController:newsVC title:@"新闻" norImage:@"NewsNormal" selectedImage:@"NewsSelected"];
        //02 本地生活
        LocalLifeViewController *localLifeVC = [[LocalLifeViewController alloc] init];
        [self addOneChildViewController:localLifeVC title:@"本地生活" norImage:@"LocalLifeNormal" selectedImage:@"LocalLifeSelected"];
        
        //03 我的
        MineViewController *mineVC = [[MineViewController alloc] init];
        [self addOneChildViewController:mineVC title:@"我的" norImage:@"MineNormal" selectedImage:@"MineSelected"];
    }
    return self;
}

-(void)addOneChildViewController:(UIViewController *)childVc title:(NSString *)title norImage:(NSString *)norImage selectedImage:(NSString *)selectedImage
{
    childVc.title = title;
    
    childVc.tabBarItem.image = [UIImage imageNamed:norImage];
    
    UIImage *selImage = [UIImage imageNamed:selectedImage];
    if (iOS7) {
        selImage = [selImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    childVc.tabBarItem.selectedImage = selImage;
    
    
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
    
    [self.customTabBar  addTabBarButton:childVc.tabBarItem];
    
}


#pragma mark - YDTabBarDelegate
-(void)tabBar:(CustomTabBar *)tabBar from:(NSInteger)from to:(NSInteger)to
{
    NSLog(@"%zd",to);
    
    self.selectedIndex = to;
}

-(void)tabBarPresentViewController:(CustomTabBar *)tabBar{

}
-(void)selectTabItem:(NSInteger)index{
    NSLog(@"index:%ld",(long)index);
}

#pragma mark -- 收到通知
#pragma mark - 来自推送消息点击之后的跳转页面
-(void)jumpToAppointmentCenter
{
    [self.customTabBar selectTabItem:0];
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
