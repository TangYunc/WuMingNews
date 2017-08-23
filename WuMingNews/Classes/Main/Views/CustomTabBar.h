//
//  CustomTabBar.h
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomTabBar;

@protocol CustomTabBarDelegate <NSObject>

-(void)tabBar:(CustomTabBar *)tabBar from:(NSInteger)from to:(NSInteger)to;
-(void)tabBarPresentViewController:(CustomTabBar *)tabBar;
-(void)selectTabItem:(NSInteger)index;

@end

@interface CustomTabBar : UIView

@property (nonatomic, weak) id <CustomTabBarDelegate> delegate;
@property (nonatomic, strong) UIView *tabBarView;
@property (nonatomic, strong) UILabel *tabBarLabel;


-(void)addTabBarButton:(UITabBarItem *)item;
-(void)selectTabItem:(NSInteger)index;

@end
