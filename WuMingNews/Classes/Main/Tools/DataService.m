//
//  DataService.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/3.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "DataService.h"
#include <CommonCrypto/CommonDigest.h>

@implementation DataService

#pragma mark Md5加密
+(NSString *)md5:(NSString *)str{
    
    //    str=[NSString stringWithFormat:@"zkch:nongtongbao%@",str];
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, strlen(cStr), result );
    
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [Mstr appendFormat:@"%02X",result[i]];
    }
    
    return [Mstr lowercaseString];
}

+(void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure
{
    NSUserDefaults *networkDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *network = [networkDefaults objectForKey:networkStatus];
    
    
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"请求接口=%@",url);
    NSLog(@"请求参数=%@",params);
    
    // 1.创建AFN管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    //    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //申明返回的结果是json类型
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 60.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSLog(@"manager.requestSerializer.HTTPRequestHeaders====%@",manager.requestSerializer.HTTPRequestHeaders);
    
    // 2.发送请求
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功");
        NSLog(@"请求成功===%@",responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (success) {
            //如果检测到返回 login == 0 ,即登陆有问题，直接退出登陆
            if([responseObject[@"succ"] intValue] == 0 && [responseObject[@"login"] intValue] == 0){
                //                [[NSNotificationCenter defaultCenter] postNotificationName:XJLoginResultNotification object:@(2)];
            }
            success(responseObject);
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        NSLog(@" http response : %ld",(long)httpResponse.statusCode);
        if ((long)httpResponse.statusCode == 401) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }else if ([network isEqual:@100]){ // 没有网络
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"没有网络可用"];
        }else {
            //            [MBProgressHUD hideHUD];
            //            [MBProgressHUD showError:@"网络有异常，请检查您的网络设置"];
        }
        
        if (failure) {
            NSLog ( @"error: %@" , error);
            failure(error);
        }
    }];
}

// 上传图片带参数
+(void)postWithUrl:(NSString *)url paramaters:(NSDictionary *)params formDataArray:(NSArray *)formDataArray success:(successBlock)success failure:(failureBlock)failure
{
    NSUserDefaults *networkDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *network = [networkDefaults objectForKey:networkStatus];
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"请求接口=%@",url);
    NSLog(@"请求参数=%@",params);
    
    // 1.创建AFN管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //申明返回的结果类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    // 2.发送请求
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (int i = 0; i <  formDataArray.count; i++ ) {
            NSLog(@"formData:%@",formData);
            [formData appendPartWithFileData:formDataArray[i][@"data"] name:formDataArray[i][@"name"] fileName:formDataArray[i][@"fileName"] mimeType:@"image/png"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress====%@",uploadProgress);
        float progress = (float)uploadProgress.completedUnitCount / (float)uploadProgress.totalUnitCount;
        //        [MBProgressHUD showMessage:@"正在上传..." andProgress:progress toView:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD HUDForView:[[UIApplication sharedApplication].windows lastObject]];
            hud.mode = MBProgressHUDModeDeterminate;
            hud.progress = progress;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (success) {
            success(responseObject);
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        NSLog(@" http response : %ld",(long)httpResponse.statusCode);
        if ((long)httpResponse.statusCode == 401) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginResultNotification object:@(2)];
            });
        }else if ([network isEqual:@100]){ // 没有网络
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"没有网络可用"];
        }else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器连接失败"];
        }
        
        if (failure) {
            NSLog ( @"error: %@" , error);
            failure(error);
        }
    }];
}



+(void)getWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure
{
    NSUserDefaults *networkDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *network = [networkDefaults objectForKey:networkStatus];
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"请求接口=%@",url);
    NSLog(@"请求参数=%@",params);
    
    // 1.创建AFN管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    //    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //申明返回的结果是json类型
    //        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 10.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSLog(@"manager.requestSerializer.HTTPRequestHeaders====%@",manager.requestSerializer.HTTPRequestHeaders);
    
    // 2.发送请求
    // 2.发送请求
    [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功 , 通知调用者请求成功
        NSLog(@"请求成功");
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        NSLog(@" http response : %ld",(long)httpResponse.statusCode);
        if ((long)httpResponse.statusCode == 401) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginResultNotification object:@(2)];
            });
        }else if ([network isEqual:@100]){ // 没有网络
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"没有网络可用"];
        }else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器连接失败"];
        }
        
        if (failure) {
            NSLog ( @"error: %@" , error);
            failure(error);
        }
    }];
}

+(void)getWechatWithURL:(NSString *)url params:(NSDictionary *)params success:(successBlock)success failure:(failureBlock)failure
{
    NSUserDefaults *networkDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *network = [networkDefaults objectForKey:networkStatus];
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSLog(@"请求接口=%@",url);
    NSLog(@"请求参数=%@",params);
    
    // 1.创建AFN管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    //    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //申明返回的结果是json类型
    //        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 10.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSLog(@"manager.requestSerializer.HTTPRequestHeaders====%@",manager.requestSerializer.HTTPRequestHeaders);
    
    // 2.发送请求
    // 2.发送请求
    [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功 , 通知调用者请求成功
        NSLog(@"请求成功");
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)task.response;
        NSLog(@" http response : %ld",(long)httpResponse.statusCode);
        if ((long)httpResponse.statusCode == 401) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginResultNotification object:@(2)];
            });
        }else if ([network isEqual:@100]){ // 没有网络
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"没有网络可用"];
        }else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器连接失败"];
        }
        
        if (failure) {
            NSLog ( @"error: %@" , error);
            failure(error);
        }
    }];
}

@end
