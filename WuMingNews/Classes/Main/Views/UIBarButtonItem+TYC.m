//
//  UIBarButtonItem+TYC.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "UIBarButtonItem+TYC.h"

@implementation UIBarButtonItem (TYC)

+(instancetype)itemWithNorImage:(NSString *)norImageName higImage:(NSString *)higImageName targe:(id)targe action:(SEL)action
{
    // 1.创建按钮
    UIButton *btn = [[UIButton alloc] init];
    // 2.设置默认状态图片
    [btn setBackgroundImage:[UIImage imageNamed:norImageName] forState:UIControlStateNormal];
    // 3.设置高亮状态图片
    [btn setBackgroundImage:[UIImage imageNamed:higImageName] forState:UIControlStateHighlighted];
    // 4.设置frame
    btn.size = btn.currentBackgroundImage.size;
    // 5.添加监听事件
    [btn addTarget:targe action:action forControlEvents:UIControlEventTouchUpInside];
    // 6.返回item
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
@end
