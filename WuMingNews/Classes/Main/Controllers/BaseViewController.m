//
//  BaseViewController.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self hideNavigationBarShadowLine:YES];
}

- (void)hideNavigationBarShadowLine:(BOOL)hide{
    if (hide) {
        //隐藏导航栏下的线
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    }
    else{
        [self.navigationController.navigationBar setShadowImage:nil];
    }
}

#pragma mark - 设置返回按钮
- (void)setIsBackButton:(BOOL)isBackButton
{
    if (_isBackButton != isBackButton) {
        _isBackButton = isBackButton;
        
        if (_isBackButton == YES) {
            // 创建返回按钮
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            backButton.frame = CGRectMake(0, 0, 56, 56);
            // 设置标题图片
            
            [backButton setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
            [backButton setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateHighlighted];
            [backButton setTitle:@"返回" forState:UIControlStateNormal];
            backButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
            backButton.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
            
            // 设置事件
            [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
            // 创建导航按钮设置到左侧
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}
#pragma mark - 返回按钮事件
- (void)backAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
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
