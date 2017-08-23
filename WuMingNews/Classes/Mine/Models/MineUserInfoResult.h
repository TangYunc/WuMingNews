//
//  MineUserInfoResult.h
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/15.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MineUserInfoResult,MineUserInfoData;
@interface MineUserInfoResult : NSObject

@property (nonatomic, assign) BOOL succ;
@property (nonatomic, copy) NSString *msg;           // 获取用户信息状态提示
@property (nonatomic, strong) MineUserInfoData *datas;

@end

@interface MineUserInfoData : NSObject

@property (nonatomic, copy) NSString *userID;               //
@property (nonatomic, copy) NSString *unionid;               // ----->用户标识
@property (nonatomic, copy) NSString *nickname;               //----->用户昵称
@property (nonatomic, copy) NSString *headimgurl;               // ----->用户头像
@property (nonatomic, copy) NSString *sex;             // ----->用户性别  0女 1男
@property (nonatomic, copy) NSString *create_time;           // ----->注册时间
@property (nonatomic, copy) NSString *create_ip;        //  ----->注册ip
@property (nonatomic, copy) NSString *last_update_time;           // ----->更新时间
@property (nonatomic, copy) NSString *last_update_ip;           // ----->更新ip
@end

