//
//  MineViewController.h
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "BaseViewController.h"


@interface MineViewController : BaseViewController

/** 通过block去执行AppDelegate中的wechatLoginByRequestForUserInfo方法 */
@property (copy, nonatomic) void (^requestForUserInfoBlock)();

@end
