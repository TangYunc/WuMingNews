//
//  ShareCustom.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/16.
//  Copyright © 2017年 com.guwu. All rights reserved.
//
// 适配
#define DevicesScale ([UIScreen mainScreen].bounds.size.height==480?1.00:[UIScreen mainScreen].bounds.size.height==568?1.00:[UIScreen mainScreen].bounds.size.height==667?1.17:1.29)

// 颜色
#define UIColorFromRGB(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// 设备类型
#define SYSTEM_VERSION   [[UIDevice currentDevice].systemVersion floatValue]

//屏幕宽度相对iPhone6屏幕宽度的比例
#define KWidth_Scale    [UIScreen mainScreen].bounds.size.width/375.0f

//微信SDK头文件
#import "WXApi.h"
#import "ShareCustom.h"

@implementation ShareCustom
static id _publishContent;//类方法中的全局变量这样用（类型前面加static）
static UIVisualEffectView *_effectView;
/*
 自定义的分享类，使用的是类方法，其他地方只要 构造分享内容publishContent就行了
 */

+(void)shareWithContent:(id)publishContent/*只需要在分享按钮事件中 构建好分享内容publishContent传过来就好了*/
{
    _publishContent = publishContent;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    
    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    _effectView.alpha = 0.3;
    _effectView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [window addSubview:_effectView];
    
    
    /**
     点击退出手势
     */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [_effectView addGestureRecognizer:tap];
    
    
    /**
     加上一层黑色透明效果
     */
    //    UIView *blackV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    //    blackV.backgroundColor = [UIColor blackColor];
    //    blackV.alpha = 0.2;
    //    [_effectView addSubview:blackV];
    
    
    /**
     Share Content
     */
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight- 163,  kScreenWidth, 163)];
    shareView.tag = 441;
    [window addSubview:shareView];
    
    UIImageView *shareImg = [[UIImageView alloc] initWithImage:[self generateImageFromColor:UIColorFromRGBA(245, 245, 245, 1.0)]];
    shareImg.frame = CGRectMake(0, 0, shareView.frame.size.width, shareView.frame.size.height);
    [shareView addSubview:shareImg];
    
    
    //MaterialWeiBoIcon
    NSArray *btnImages = @[@"MaterialWeChatLineIcon", @"MaterialWeChatFriendsIcon"];
    
    for (NSInteger i = 0; i < btnImages.count; i++) {
        CGFloat bt_width =  50;
        CGFloat bt_height =  72;
        CGFloat gap = (shareView.frame.size.width - 20 * 2  - 4*bt_width) / 3.0;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20 + (bt_width + gap) * i, 20, bt_width, bt_height);
        [button setImage:[UIImage imageNamed:btnImages[i]] forState:UIControlStateNormal];
        button.tag = 331+i;
        [button addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [shareView addSubview:button];
    }
    UIButton *button = (UIButton *)[shareView viewWithTag:331];
    
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, button.bottom + 21, shareView.width, 50)];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:UIColorFromRGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [cancleBtn setBackgroundColor:[UIColor whiteColor]];
    //    [cancleBtn setImage:[UIImage imageNamed:@"MaterialShareCancleIcon"] forState:UIControlStateNormal];
    cancleBtn.tag = 339;
    [cancleBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.alpha = 1.0;
    [shareView addSubview:cancleBtn];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    //    shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
    shareView.top = kScreenHeight;
    _effectView.contentView.alpha = 0;
    [UIView animateWithDuration:0.35f animations:^{
        shareView.top = kScreenHeight- 163;
        //        shareView.transform = CGAffineTransformMakeScale(1, 1);
        _effectView.contentView.alpha = 0.7;
    } completion:^(BOOL finished) {
        
    }];
}



+(void)shareBtnClick:(UIButton *)btn
{
    if (btn.tag == 339) {
        
        [self dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shareFail" object:nil];
        });
        return;
    }
    switch (btn.tag) {
        case 331:
        {
            [self SendTextImageLink:1 publishContent:_publishContent];
        }
            break;
            
        case 332:
        {
            [self SendTextImageLink:0 publishContent:_publishContent];
            
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - 根据颜色生成图片
+ (UIImage *)generateImageFromColor:(UIColor *)color{
    
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorImage;
}
+ (void)dismiss {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *shareView = [window viewWithTag:441];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    //    shareView.transform = CGAffineTransformMakeScale(1, 1);
    shareView.top = kScreenHeight - 163;
    [UIView animateWithDuration:0.35f animations:^{
        shareView.top = kScreenHeight;
        //        shareView.transform = CGAffineTransformMakeScale(1/300.0f, 1/270.0f);
        _effectView.contentView.alpha = 0;
    } completion:^(BOOL finished) {

        [shareView removeFromSuperview];
        [_effectView removeFromSuperview];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shareFail" object:nil];
        });
    }];
}
/** 发送图片文字链接*/
+ (void)SendTextImageLink:(int)index publishContent:(id)thePublishContent {
    if (![WXApi isWXAppInstalled]) {
        NSLog(@"请移步App Store去下载微信客户端");
    }else {
        SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
        sendReq.bText = NO;//YES表示使用文本信息 NO表示不使用文本信息
        // 0：分享到好友列表 1：分享到朋友圈  2：收藏
        sendReq.scene = index;
        
        // 2.创建分享内容
        WXMediaMessage *message = [WXMediaMessage message];
        //分享标题
        message.title = thePublishContent[@"title"];
        // 描述
        message.description = thePublishContent[@"description"];
        //分享图片,使用SDK的setThumbImage方法可压缩图片大小
        [message setThumbImage:[UIImage imageNamed:@"shareImageIcon"]];
        
        //创建多媒体对象
        WXWebpageObject *webObj = [WXWebpageObject object];
        // 点击后的跳转链接
        webObj.webpageUrl = thePublishContent[@"url"];
        message.mediaObject = webObj;
        sendReq.message = message;
        [WXApi sendReq:sendReq];
    }
    [self dismiss];
}
@end
