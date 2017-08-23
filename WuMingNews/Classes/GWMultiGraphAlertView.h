//
//  GWMultiGraphAlertView.h
//  cps
//
//  Created by Mr_Tang on 2016/12/13.
//  Copyright © 2016年 com.guwu. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "GWShareResult.h"

@interface GWMultiGraphAlertView : UIView
{
    UILabel *_titleLabel;
    UILabel *_cancelLabel;
}

@property (copy, nonatomic) void (^requestForUserInfoBlock)();
@property(nonatomic,copy)NSString *titleStr;
@property(nonatomic,strong)UIViewController *alertVC;


@end
