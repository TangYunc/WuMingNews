//
//  UIButton+TYC.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/27.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "UIButton+TYC.h"

@implementation UIButton (TYC)

-(void)startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color withObjectStr:(NSString *)objectStr{
    
    //倒计时时间
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        //倒计时结束，关闭
        if (timeOut <= 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundColor = mColor;
                [self setTitle:title forState:UIControlStateNormal];
                [self setTitleColor:UIColorFromRGBA(50, 50, 50, 1.0) forState:UIControlStateNormal];
                self.enabled = YES;
            });
        } else {
            int seconds = timeOut % 60;
            NSString *timeStr = [NSString stringWithFormat:@"%0.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backgroundColor = color;
                [self setTitle:[NSString stringWithFormat:@"%@%@",timeStr,subTitle] forState:UIControlStateNormal];
                [self setTitleColor:UIColorFromRGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
                self.enabled = NO;
                if ([objectStr isEqualToString:@"loginVc"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:VerificationCodeTime object:[NSNumber numberWithInteger:seconds]];
                }
                
            });
            timeOut--;
        }
    });
    dispatch_resume(_timer);
}
@end
