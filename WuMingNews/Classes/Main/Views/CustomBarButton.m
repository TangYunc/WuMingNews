//
//  CustomBarButton.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//
#define customColor colorWithRed:221/255.0 green:40/255.0 blue:23/255.0 alpha:1

#import "CustomBarButton.h"

@implementation CustomBarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1.设置图片居中
        self.imageView.contentMode = UIViewContentModeCenter;
        // 2.设置标题居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 3.设置标题的大小
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        // 4.设置标题颜色
        [self setTitleColor:[UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:1] forState:UIControlStateNormal];
        
        // 5.设置选中状态的颜色
        [self setTitleColor:[UIColor customColor] forState:UIControlStateSelected];
        
    }
    return self;
}

-(void)setItem:(UITabBarItem *)item
{
    _item = item;
    
    // 1.设置按钮默认状态的图片
    [self setImage:item.image forState:UIControlStateNormal];
    // 2.设置按钮选中状态的图片
    [self setImage:item.selectedImage forState:UIControlStateSelected];
    // 3.设置按钮的标题
    [self setTitle:item.title forState:UIControlStateNormal];
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW = self.width;
    CGFloat imageH = self.height * 0.6;
    CGFloat imageX = 0;
    CGFloat imageY = 2;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = self.height * 0.6;
    CGFloat titleW = self.width;
    CGFloat titleH = self.height - titleY;
    return CGRectMake(titleX, titleY, titleW, titleH);
}


-(void)setHighlighted:(BOOL)highlighted
{
    
}


@end
