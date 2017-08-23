//
//  CustomWechatLoginItem.h
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/27.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomWechatLoginItem : UIControl
{
    UIImageView *_loginImageView;// 登录图片
    UILabel *_loginTitleLabel;// 登录标题Label
}

@property (nonatomic,strong) UIImageView *loginImageView;
@property (nonatomic,strong) UILabel *loginTitleLabel;

// 设置imageView
- (void)setTheLoginImageView:(NSString *)imageName;

// 设置标题Label
- (void)setTheLoginTitleLabel:(NSString *)loginTitle;
@end
