//
//  LocalLifeViewController.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "LocalLifeViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <JavaScriptCore/JavaScript.h>
#import "webViewController.h"



@interface LocalLifeViewController ()<UIWebViewDelegate>

@property(nonatomic,strong)UIWebView *webView;
@property (nonatomic, copy) NSString *wapUrl;
@property (nonatomic, assign) BOOL isJSSelected;
@property (nonatomic, assign) BOOL isShowMB;

@end

@implementation LocalLifeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGBA(240, 240, 240, 1.0);
    
    [self creatWebView];
    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadDatas];
    }];
    [self loadDatas];
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.isShowMB = YES;
    self.isJSSelected = YES;
    
}
//加载数据
- (void)loadDatas{
    // 1.请求参数
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseApi,localLifeWuming];
    
    // 发送请求
    [DataService postWithURL:url params:nil success:^(id responseObject) {
        
        NSLog(@"get_UserInfo_Api=====%@",responseObject);
        NSString *tempUrl = responseObject[@"url"];
        NSString *wapUrl = [NSString stringWithFormat:@"%@&type=ios",tempUrl];
        NSLog(@"wapUrl:%@",wapUrl);
        [self loadString:wapUrl];
        
    } failure:^(NSError *error) {
    }];
}
-(void)creatWebView
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    _webView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:251/255.0 alpha:1];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    _webView.scrollView.showsVerticalScrollIndicator = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.allowsInlineMediaPlayback = YES;
    _webView.mediaPlaybackRequiresUserAction = YES;
    //     自动对页面进行缩放以适应屏幕
    _webView.scalesPageToFit = YES;
}

// 让浏览器加载指定的字符串,使用m.baidu.com进行搜索
- (void)loadString:(NSString *)str
{
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    // 3. 发送请求给服务器
    [self.webView loadRequest:request];
}



#pragma mark - UIWebDelegate
/**
 *  作用：一般用来拦截webView发出的所有请求（加载新的网页）
 *  每当webView即将发送一个请求之前，会先调用这个方法
 *
 *  @param request        即将要发送的请求
 *
 *  @return YES ：允许发送这个请求  NO ：不允许发送这个请求，禁止加载这个请求
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"本地生活webView将要显示");
    if (self.isShowMB) {
        self.isShowMB = NO;
        [MBProgressHUD showMessage:@"拼命加载中,请稍等..." toView:webView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:_webView animated:YES];
//            [MBProgressHUD showError:@"您的网络可能有点差哦,请稍后再试!"];
        });
    }
    return  YES;
}

/**
 *  UIWevView开始加载内容时调用
 */
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"正在开始加载.......");
    
}
/**
 *  UIWevView加载完毕时调用
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    //定义好JS要调用的方法
    [self.webView.scrollView.mj_header endRefreshing];
        
    NSLog(@"本地生活webView加载完毕");
    [MBProgressHUD hideHUDForView:webView animated:YES];
    
    JSContext *context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"wxapploadcomplet"] = ^(){
        NSLog(@"停止继续加载的样式");
        [MBProgressHUD hideHUDForView:self.webView animated:YES];
    };
    context[@"wxappopenurl"] = ^(){
        NSArray *prams = [JSContext currentArguments];
        NSString *arraySting = [[NSString alloc]init];
        for (id obj in prams) {
            NSLog(@"wxappopenurl====%@",obj);
            arraySting = [arraySting stringByAppendingFormat:@"%@",obj];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isJSSelected) {
                self.isJSSelected = NO;
                NSString *wapUrlStr = [NSString stringWithFormat:@"%@",arraySting];
                [self setUpSubviews:wapUrlStr];
            }
        });
    };
    
}

/**
 *  加载失败时调用
 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"加载失败.......");
    [self.webView.scrollView.mj_header endRefreshing];
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
}
- (void)setUpSubviews:(NSString *)wapUrl{
    
    
    webViewController *webVC = [[webViewController alloc] init];
    webVC.wap_url = wapUrl;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)dealloc
{
    NSLog(@"本地生活dealloc");
    self.webView.delegate = nil;
    [self.webView stopLoading];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
