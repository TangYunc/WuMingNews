//
//  DataService.h
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/3.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^successBlock)(id responseObject);
typedef void (^failureBlock)(NSError *error);
typedef void (^dictonaryBlock)(NSDictionary *responseObject);



@interface DataService : NSObject

//加密
+(NSString *)md5:(NSString *)str;

+(void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure;
+ (void)postWithUrl:(NSString *)url paramaters:(NSDictionary *)params formDataArray:(NSArray *)formDataArray success:(successBlock)success failure:(failureBlock)failure;

+(void)getWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure;
+(void)getWechatWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure;

@end
