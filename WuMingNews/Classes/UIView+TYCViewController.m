//
//  UIView+TYCViewController.m
//  cps
//
//  Created by Mr_Tang on 2016/10/28.
//  Copyright © 2016年 com.guwu. All rights reserved.
//

#import "UIView+TYCViewController.h"

@implementation UIView (TYCViewController)

// 获取视图所在的视图控制器
- (UIViewController *)viewControler
{
    // 1.获取当前视图的下一响应者
    UIResponder *responder = self.nextResponder;
    
    // 2.判断当前对象是否是视图控制器
    while (YES) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        } else {
            responder = responder.nextResponder;
            if (responder == nil) {
                return nil;
            }
        }
    }
}

@end
