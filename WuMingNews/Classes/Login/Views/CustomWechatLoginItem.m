//
//  CustomWechatLoginItem.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/27.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "CustomWechatLoginItem.h"

@implementation CustomWechatLoginItem

// 重写初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _loginImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60 * KWidth_ScaleW, 60 * KWidth_ScaleH)];
        _loginImageView.clipsToBounds = YES;
        _loginImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_loginImageView];
        
        _loginTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _loginImageView.bottom + 14 * KWidth_ScaleH, self.width, 14 * KWidth_ScaleH)];
        _loginTitleLabel.font = [UIFont systemFontOfSize:14.f];
        _loginTitleLabel.textColor = UIColorFromRGBA(153, 153, 153, 1.0);
        _loginTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_loginTitleLabel];
        _loginImageView.centerX = _loginTitleLabel.centerX;
    }
    return self;
}

// 设置ImageView
- (void)setTheLoginImageView:(NSString *)imageName{
    
    _loginImageView.image = [UIImage imageNamed:imageName];
}

// 设置累计标题Label
- (void)setTheLoginTitleLabel:(NSString *)loginTitle{
    
    _loginTitleLabel.text = loginTitle;
}
@end
