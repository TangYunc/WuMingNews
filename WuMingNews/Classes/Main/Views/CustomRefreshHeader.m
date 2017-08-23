//
//  CustomRefreshHeader.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/15.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "CustomRefreshHeader.h"

@interface CustomRefreshHeader ()

@property (strong, nonatomic) NSMutableDictionary *stateTitles;

@end
@implementation CustomRefreshHeader

- (void)prepare{
    
    [super prepare];
    // 初始化文字
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshHeaderIdleText] forState:MJRefreshStateIdle];
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshHeaderPullingText] forState:MJRefreshStatePulling];
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshHeaderRefreshingText] forState:MJRefreshStateRefreshing];
    
}
- (void)setTitle:(NSString *)title forState:(MJRefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
    self.stateLabel.textColor = [UIColor whiteColor];
    self.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];
}

#pragma mark - 懒加载
- (NSMutableDictionary *)stateTitles
{
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

@end
