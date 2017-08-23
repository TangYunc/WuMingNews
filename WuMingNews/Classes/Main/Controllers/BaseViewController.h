//
//  BaseViewController.h
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, assign) BOOL isBackButton;

- (void)hideNavigationBarShadowLine:(BOOL)hide;
- (UIImage *)generateImageFromColor:(UIColor *)color;

@end
