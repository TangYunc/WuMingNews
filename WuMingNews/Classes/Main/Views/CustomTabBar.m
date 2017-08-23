//
//  CustomTabBar.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "CustomTabBar.h"
#import "CustomBarButton.h"

@interface CustomTabBar ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *tabBarButtons;
@property (nonatomic, weak) CustomBarButton *currentSelectedBtn;
@property (nonatomic, assign) NSInteger btnTag;         // 点击的是tabbar的哪一个按钮

@end
@implementation CustomTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1.设置背景
        [self setupBg];
    }
    return self;
}

-(void)setupBg
{
    //设置TabBar的backgroundColor
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbarBg"]];
    
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.设置选项卡的frame
    [self setupTabBarBtnFrame];
}
-(void)setupTabBarBtnFrame
{
    NSUInteger count = self.tabBarButtons.count;
    //    CGFloat btnWidth = self.width / (count + 1);
    CGFloat btnWidth = self.width / count;
    CGFloat btnHeight = self.height;
    for (int i = 0; i < count; i ++) {
        // 1.取出对应的按钮
        UIButton *btn = self.tabBarButtons[i];
        // 2.设算frame
        CGFloat btnW = btnWidth;
        CGFloat btnH = btnHeight;
        CGFloat btnY = 0;
        CGFloat btnX = i * btnW;
        //        if (i >= count / 2) {
        //            btnX = (i + 1) * btnW;
        //        }
        
        // 3.设置frame
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(btnWidth * 2.5 + 10, 0, 14, 14)];
    view.clipsToBounds = YES;
    view.layer.cornerRadius = 7;
    view.userInteractionEnabled = NO;
    self.tabBarView = view;
    [self addSubview:view];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 14, 10)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = NSTextAlignmentCenter;
    self.tabBarLabel = label;
    [view addSubview:label];
    
}
-(void)addTabBarButton:(UITabBarItem *)item
{
    // 1.创建按钮
    CustomBarButton *tabBarButton = [[CustomBarButton alloc] init];
    
    // 2.设置item
    tabBarButton.item = item;
    
    // 添加tag
    tabBarButton.tag = self.tabBarButtons.count;
    
    // 添加按钮的监听事件
    [tabBarButton addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchDown];
    
    
    // 3.添加选项卡到自定义的tabBar上
    [self addSubview:tabBarButton];
    
    // 4.添加当前的按钮到数组中
    [self.tabBarButtons addObject:tabBarButton];
    
    
    // 5.判断是否是第一个按钮
    if (self.tabBarButtons.count == 1) {
        // 第一个按钮
        [self btnOnClick:tabBarButton];
    }
    
    
    
}


-(void)btnOnClick:(CustomBarButton *)btn;
{
    self.btnTag = btn.tag;
    if (self.btnTag == 0) {
        NSLog(@"点击新闻控制器");
    }else if (self.btnTag == 1){
        NSLog(@"点击本地生活控制器");
    }else{
        NSLog(@"点击我的控制器");
    }
    
    // 0.通知代理
    if ([self.delegate respondsToSelector:@selector(tabBar:from:to:)]) {
        [self.delegate tabBar:self from:self.currentSelectedBtn.tag to:btn.tag];
    }
    
    // 1.取消选中上一次选中的按钮
    self.currentSelectedBtn.selected = NO;
    
    // 2.选中当前的按钮
    btn.selected = YES;
    
    // 3.记录当前选中的按钮
    self.currentSelectedBtn = btn;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"点击了取消，不做处理");
            break;
            
        case 1:
            NSLog(@"点击了确定,通知代理");
            // 通知代理
            if ([self.delegate respondsToSelector:@selector(tabBarPresentViewController:)]) {
                [self.delegate tabBarPresentViewController:self];
            }
            break;
        default:
            break;
    }
}




#pragma mark - tabBarButtons的懒加载
-(NSMutableArray *)tabBarButtons
{
    if (!_tabBarButtons) {
        _tabBarButtons = [NSMutableArray array];
    }
    return _tabBarButtons;
}


// 手动调用tabBar按钮点击
-(void)selectTabItem:(NSInteger)index{
    CustomBarButton *btn= _tabBarButtons[index];
    [self btnOnClick:btn];
}

@end
