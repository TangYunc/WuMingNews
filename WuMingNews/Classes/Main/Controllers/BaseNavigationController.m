//
//  BaseNavigationController.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

+(void)initialize
{
    
    
    [self setupNavTheme];
    
    [self stupItemTheme];
}

+(void)stupItemTheme
{
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    
    NSMutableDictionary *norMd = [NSMutableDictionary dictionary];
    norMd[NSForegroundColorAttributeName] = [UIColor whiteColor];
    norMd[UITextAttributeTextShadowOffset] = [NSValue valueWithUIOffset:UIOffsetZero];
    norMd[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    [item setTitleTextAttributes:norMd forState:UIControlStateNormal];
    
    NSMutableDictionary *higMd = [NSMutableDictionary dictionaryWithDictionary:norMd];
    higMd[NSForegroundColorAttributeName] = [UIColor redColor];
    [item setTitleTextAttributes:higMd forState:UIControlStateHighlighted];
}

+(void)setupNavTheme
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, UIColorFromRGBA(199, 9, 9 , 1.0).CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [navBar setBackgroundImage:colorImage forBarMetrics:UIBarMetricsDefault];
    //    navBar.barTintColor = [UIColor colorWithPatternImage:colorImage];
    //    navBar.translucent = NO;
    [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                    [UIFont systemFontOfSize:18], NSFontAttributeName,
                                    nil]];
    
}


-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    if (self.childViewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:YES];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown;
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
