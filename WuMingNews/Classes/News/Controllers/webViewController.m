//
//  webViewController.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/19.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "webViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <JavaScriptCore/JavaScript.h>
#import "ShareCustom.h"
//#import "TestJSObject.h"

@interface webViewController ()<UIWebViewDelegate>
{
    UILabel *_titleLabel;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic,strong,readwrite) UIBarButtonItem *returnButton;
@property (nonatomic,strong,readwrite) UIBarButtonItem *closeItem;
@property (nonatomic)UIButton* theRightButton;
@property (nonatomic, strong)GWMultiGraphAlertView *multiGraphAlertView;

@property (nonatomic, assign)BOOL isJSSelected;
@property (nonatomic, assign)BOOL isShowMB;
@property (nonatomic, assign)BOOL isJumpLogin;
@property (nonatomic, assign)BOOL alertLoginPromptView;
@property (nonatomic, strong)NSDictionary *shareParam;


@end

@implementation webViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = self.returnButton;
    // 02 自定义标题视图
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200 * KWidth_ScaleW, 44 * KWidth_ScaleH)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:18 * KWidth_ScaleW];
    self.navigationItem.titleView = _titleLabel;
    
    
    [self creatWebView];
    NSString *wxunionid = [KUserDefault objectForKey:unionid];
    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSString *theUrl = [NSString stringWithFormat:@"%@&type=ios&unionid=%@",self.wap_url,wxunionid];
        [self loadString:theUrl];
    }];
    //注册通知，登录后收到通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:LoginResultNotification object:nil];
    //注册通知，点击手机号登录后收到通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickPhoneLoginBtn:) name:@"clickPhoneLoginBtn" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    UIApplication *app = [UIApplication sharedApplication];
    app.statusBarStyle = UIStatusBarStyleLightContent;
    UIImage *theImage = [self generateImageFromColor:UIColorFromRGBA(199, 9, 9, 1.0)];
    [self.navigationController.navigationBar setBackgroundImage:theImage forBarMetrics:UIBarMetricsDefault];
    self.isJSSelected = YES;
    self.isShowMB = YES;
    self.alertLoginPromptView = NO;
    NSString *wxunionid = [KUserDefault objectForKey:unionid];
    NSString *theUrl = [NSString stringWithFormat:@"%@&type=ios&unionid=%@",self.wap_url,wxunionid];
    [self loadString:theUrl];
    
}
- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    if (!self.alertLoginPromptView) {
        
        self.webView.delegate = nil;
        [self.webView stopLoading];
        self.webView = nil;
        [self.webView removeFromSuperview];
        self.view  = nil;
    }
}
-(void)creatWebView
{
    _webView = [[UIWebView alloc] init];
    _webView.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:251/255.0 alpha:1];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    _webView.scrollView.showsVerticalScrollIndicator = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.allowsInlineMediaPlayback = YES;
    _webView.mediaPlaybackRequiresUserAction = YES;
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    
    
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
-(GWMultiGraphAlertView*)multiGraphAlertView{
    if (!_multiGraphAlertView) {
        _multiGraphAlertView = [[GWMultiGraphAlertView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _multiGraphAlertView.alertVC = self;
        
        
    }
    return _multiGraphAlertView;
}
- (UIBarButtonItem *)returnButton {
    if (!_returnButton) {
        _returnButton = [[UIBarButtonItem alloc] init];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"backBtn"];
        [button setImage:image forState:UIControlStateNormal];//这是一张“<”的图片
        [button addTarget:self action:@selector(respondsToReturnToBack:) forControlEvents:UIControlEventTouchUpInside];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.frame = CGRectMake(15, 0, 20, 20);
        _returnButton.customView = button;
        
    }
    return _returnButton;
}

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(respondsToReturnToFind:)];
    }
    return _closeItem;
}
- (UIButton *)theRightButton{
    if (!_theRightButton) {
        
        _theRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        _theRightButton.frame = CGRectMake(0, 0, 20, 20);
        [_theRightButton setImage:[UIImage imageNamed:@"RightItemShareIcon"] forState:UIControlStateNormal];
        // 添加事件
        [_theRightButton addTarget:self action:@selector(theRightButtonItemClicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:_theRightButton];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        [_theRightButton sizeToFit];
    }
    return _theRightButton;
}
#pragma mark -- 按钮点击事件
- (void)respondsToReturnToBack:(UIButton *)sender {
    if ([self.webView canGoBack]) {//判断当前的H5页面是否可以返回
        //如果可以返回，则返回到上一个H5页面，并在左上角添加一个关闭按钮
        [self.webView goBack];
        self.navigationItem.leftBarButtonItems = @[self.returnButton, self.closeItem];
    } else {
        //如果不可以返回，则直接:
        NSUserDefaults*pushJudge = [NSUserDefaults standardUserDefaults];
        if([[pushJudge objectForKey:@"push"]isEqualToString:@"push"]) {
            //是收到极光通知过来的
            [pushJudge setObject:@"" forKey:@"push"];
            [pushJudge synchronize];//记得立即同步
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }else{
//            if (self.navigationController.viewControllers.count == 1) {
//                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//            }else{
//                [self.navigationController popViewControllerAnimated:YES];
//            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)respondsToReturnToFind:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)theRightButtonItemClicked{
    
    NSLog(@"点击分享");
    [ShareCustom shareWithContent:self.shareParam];
    
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
    NSLog(@"WebViewController开始加载");
    if (self.isShowMB) {
        self.isShowMB = NO;
        if (![self.titleNameStr isEqualToString:@"关于我们"]) {
            [MBProgressHUD showMessage:@"拼命加载中，请稍等..." toView:_webView];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:_webView animated:YES];
//            [MBProgressHUD showError:@"您的网络可能有点差哦,请稍后再试!"];
        });
    }
    NSString *urstr = request.URL.absoluteString;
    NSLog(@"urstr:%@",urstr);
    
    NSDictionary *urlDic = [self getURLParameters:urstr];
    NSString *tempUnionid = nil;
    if ([urlDic[@"unionid"] isKindOfClass:[NSArray class]]) {
        NSArray *tempUnionids = urlDic[@"unionid"];
        tempUnionid = tempUnionids[0];
    }else{
    
        tempUnionid = urlDic[@"unionid"];
    }
    NSString *wxunionid = [KUserDefault objectForKey:unionid];

    // 判断当前是否为未登录tempUnionidStr
    NSString *tempUnionidStr = @"type=ios";
    NSRange rangUnionidStr = [urstr rangeOfString:tempUnionidStr];
    
    if (rangUnionidStr.location != NSNotFound) {
        NSLog(@"当前有type=ios");
        if (tempUnionid == nil || tempUnionid == Nil || [tempUnionid isEqualToString:@""]) {
            NSString *theUrl = [NSString stringWithFormat:@"%@&type=ios&unionid=%@",urstr,wxunionid];
            [self loadString:theUrl];
        }
    } else {
        NSLog(@"当前没有type=ios");
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
    
    NSLog(@"WebViewController开始完毕");
    [MBProgressHUD hideHUDForView:_webView animated:YES];
     NSString *article_title = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"title\").value"];
    NSString *share_title = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"share_title\").value"];
    NSString *share_url = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"share_url\").value"];
    NSString *share_description = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"share_description\").value"];
    if (![article_title isEqualToString:@""]) {
        self.titleLabel.text = article_title;
    }else{
        self.titleLabel.text = self.titleNameStr;
    }
    NSArray *sharePrams = [NSArray array];
    if (share_title.length > 0 && share_url.length > 0 && share_description.length > 0) {
        sharePrams = @[share_title,share_description,share_url];
    }
    if (sharePrams.count == 3) {
        self.theRightButton.hidden = NO;
        self.shareParam = @{@"url":sharePrams[2],@"title":sharePrams[0],@"description":sharePrams[1]};
    }else{
    
        self.theRightButton.hidden = YES;
    }
    
    [self convertJSFunctionsToOCMethods];
    
    
}

/**
 *  加载失败时调用
 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"加载失败.......");
    [MBProgressHUD hideHUDForView:_webView animated:YES];
    [self.webView.scrollView.mj_header endRefreshing];
}
- (void)convertJSFunctionsToOCMethods{

    //定义好JS要调用的方法, share就是调用的share方法名
    JSContext *context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    __weak typeof(self) weakSelf = self;
    context[@"wxapplogin"] = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf alertLoginView];
        });
        
    };
    context[@"wxappopenurl"] = ^(){
        NSArray *prams = [JSContext currentArguments];
        NSString *arraySting = [[NSString alloc]init];
        for (id obj in prams) {
            NSLog(@"wxappopenurl====%@",obj);
            arraySting = [arraySting stringByAppendingFormat:@"%@",obj];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.isJSSelected) {
                weakSelf.isJSSelected = NO;
                NSString *wxunionid = [KUserDefault objectForKey:unionid];
                NSString *wapUrlStr = [NSString stringWithFormat:@"%@&type=ios&unionid=%@",arraySting,wxunionid];
                [weakSelf setUpSubviews:wapUrlStr];
            }
        });
    };
}

- (void)alertLoginView{

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.multiGraphAlertView];
}
- (void)setUpSubviews:(NSString *)wapUrl{
    
    
    webViewController *webVC = [[webViewController alloc] init];
    webVC.wap_url = wapUrl;
    
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -- 通知
- (void)loginSuccess:(NSNotification *)notify{
    NSString *theStr = notify.object;
    if ([theStr isEqualToString:@"1"]) {
        //登录成功
        self.isJumpLogin = YES;
        NSString *wxunionid = [KUserDefault objectForKey:unionid];
        NSString *theUrl = [NSString stringWithFormat:@"%@&type=ios&unionid=%@",self.wap_url,wxunionid];
        [self loadString:theUrl];
    }else{
        //退出登录
        NSLog(@"//退出登录");
    }
}
- (void)clickPhoneLoginBtn:(NSNotification *)notify{

    self.alertLoginPromptView = YES;
}
/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
- (NSMutableDictionary *)getURLParameters:(NSString *)urlStr {
    
    // 查找参数
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    // 以字典形式将参数返回
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    NSLog(@"params:%@" ,params);
    
    return params;
}
- (void)dealloc
{
    NSLog(@"WebViewControllerdealloc");
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
