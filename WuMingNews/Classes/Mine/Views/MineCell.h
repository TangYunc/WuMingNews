//
//  MineCell.h
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineCell : UITableViewCell
{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
    UIImageView *_auxiliaryImageView;
    UIView *_bottomView;
}

@property(nonatomic,strong)NSDictionary *theDic;
@end
