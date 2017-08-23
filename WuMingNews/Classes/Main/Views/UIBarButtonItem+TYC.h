//
//  UIBarButtonItem+TYC.h
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (TYC)

+(instancetype)itemWithNorImage:(NSString *)norImageName higImage:(NSString *)higImageName targe:(id)targe action:(SEL)action;

@end
