//
//  MineViewController.m
//  WuMingNews
//
//  Created by 唐云川 on 2017/6/2.
//  Copyright © 2017年 com.guwu. All rights reserved.
//

#import "MineViewController.h"
#import "UIImageView+WebCache.h"
#import "MineCell.h"
#import "MineUserInfoResult.h"
#import "webViewController.h"
#import "CustomLoginButtn.h"
#import "LoginViewController.h"

@interface MineViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,WXApiDelegate>
{
    UILabel *_titleLabel;
    UIImageView *_bjImageView;
    UIImageView *_headerPortraitImageView;
    UILabel *_nameLabel;
    UILabel *_loginStyleLabel;
    
}
@property (nonatomic, assign) BOOL isLoginAndLogout;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIColor *backColor;
@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *dataLists;

@property (nonatomic, strong) NSIndexPath *theIndexPath;
@property (nonatomic, strong) UILabel *cacheLabel;
@property (nonatomic, copy) NSString *collection_url;
@property (nonatomic, copy) NSString *aboutus_url;
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGBA(245, 245, 245, 1.0);
    self.title = @"";
    
    self.tableView.mj_header = [CustomRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    //初始化数据
    BOOL theLogin = [[KUserDefault objectForKey:IsLogin] boolValue];
    NSArray *datas = nil;
    if (!theLogin) {
                datas = @[
                           @[@{@"image":[UIImage imageNamed:@"MyCollectionIcon"],@"title":@"我的收藏"},
                             @{@"image":[UIImage imageNamed:@"ClearCacheIcon"],@"title":@"清理缓存"}
                             ],
                           
                           @[@{@"image":[UIImage imageNamed:@"AboutUsIcon"],@"title":@"关于我们"}]
                           ];
    }else{
                datas = @[
                           @[@{@"image":[UIImage imageNamed:@"MyCollectionIcon"],@"title":@"我的收藏"},
                             @{@"image":[UIImage imageNamed:@"ClearCacheIcon"],@"title":@"清理缓存"}
                             ],
                           
                           @[@{@"image":[UIImage imageNamed:@"AboutUsIcon"],@"title":@"关于我们"},
                             @{@"image":[UIImage imageNamed:@"LogOutIcon"],@"title":@"退出登录"}]
                           ];
    }
    self.dataLists = [datas mutableCopy];
    [self Cache];
    [self setUpTheViews];
    

    //注册通知，登录后收到通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:LoginResultNotification object:nil];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    [self headerRereshing];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.navigationController.navigationBar setBackgroundImage:[self generateImageFromColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    });
    self.backView.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.backView.hidden = YES;
}
- (void)headerRereshing{

    [self loadDatas];
    [self loadCollectionAndAboutUsDatas];
}
//加载数据
- (void)loadDatas{
    // 1.请求参数
    NSString *accessToken = [KUserDefault objectForKey:WX_ACCESS_TOKEN];
    NSString *auth_key = [DataService md5:@"121authkey"];
    NSString *theUnionid = [KUserDefault objectForKey:unionid];
    if (accessToken == nil || accessToken == Nil) {
        return;
    }
    if (theUnionid == nil || theUnionid == Nil) {
        return;
    }
    NSMutableDictionary *tempPara = [NSMutableDictionary dictionary];
    [tempPara setObject:accessToken forKey:@"token"];
    [tempPara setObject:theUnionid forKey:@"unionid"];
    [tempPara setObject:auth_key forKey:@"auth_key"];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseApi,get_UserInfo_Api];
    
    // 发送请求
    [DataService postWithURL:url params:tempPara success:^(id responseObject) {
        
        NSLog(@"get_UserInfo_Api=====%@",responseObject);
        if(responseObject[@"succ"])
        {
            
            [_headerPortraitImageView sd_setImageWithURL:[NSURL URLWithString:responseObject[@"data"][@"headimgurl"]] placeholderImage:[UIImage imageNamed:@"DefaultUserHeadPotritIcon"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                _headerPortraitImageView.clipsToBounds = YES;
            }];
            
            if (responseObject[@"data"][@"nickname"] != nil || ![responseObject[@"data"][@"nickname"] isEqualToString:@""]) {
                
                _nameLabel.hidden = NO;
            }
            _nameLabel.text = responseObject[@"data"][@"nickname"];
        }else {
            if (responseObject[@"msg"]) {
                [MBProgressHUD showError:responseObject[@"msg"]];
            }
        }
    } failure:^(NSError *error) {
    }];
}

//加载数据
- (void)loadCollectionAndAboutUsDatas{
    // 1.请求参数
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseApi,collectionAndAboutUs];
    
    // 发送请求
    [DataService postWithURL:url params:nil success:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        NSLog(@"loadCollectionAndAboutUsDatas=====%@",responseObject);
        self.collection_url = responseObject[@"collection_url"];
        self.aboutus_url = responseObject[@"aboutus_url"];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}


- (void)setUpTheViews{
    
    self.view.backgroundColor = [UIColor grayColor];
    self.headerHeight = 188 * KWidth_ScaleH;
    [self.view addSubview:self.tableView];
    
    //去掉背景图片
    [self.navigationController.navigationBar setBackgroundImage:[self generateImageFromColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    //去掉底部线条
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    //添加背景view
    CGRect backView_frame = CGRectMake(0, -20, kScreenWidth, 44+20);
    UIView *backView = [[UIView alloc] initWithFrame:backView_frame];
    UIColor *backColor = UIColorFromRGBA(199, 9, 0, 0.0);
    backView.backgroundColor = [backColor colorWithAlphaComponent:0.0];
    [self.navigationController.navigationBar addSubview:backView];
    self.backView = backView;
    self.backColor = backColor;
    
    
    //header
    CGRect bounds = CGRectMake(0, 0, kScreenWidth, self.headerHeight);
    UIView *contentView = [[UIView alloc] initWithFrame:bounds];
    contentView.backgroundColor = [UIColor blackColor];
    //背景
    //1.背景视图
    _bjImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.headerHeight)];
    _bjImageView.image = [self generateImageFromColor:UIColorFromRGBA(199, 9, 9, 1.0)];
    _bjImageView.userInteractionEnabled = YES;
    
    //2.头像
    _headerPortraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _bjImageView.bounds.size.height - 66 - 60, 66, 66)];
    _headerPortraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headerPortraitImageView.layer.cornerRadius = 66 / 2;
//    _headerPortraitImageView.clipsToBounds = YES;
    [_bjImageView addSubview:_headerPortraitImageView];
    _headerPortraitImageView.centerX = _bjImageView.centerX;
    _headerPortraitImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapAction:)];
    [_headerPortraitImageView addGestureRecognizer:headerTap];
    _headerPortraitImageView.hidden = YES;
    //3.店名
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _bjImageView.bounds.size.height - 20 - 20, _bjImageView.width, 20)];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:14.f];
    [_bjImageView addSubview:_nameLabel];
    _nameLabel.centerX = _bjImageView.centerX;
    _nameLabel.hidden = YES;
    
    //创建微信登录和手机号登录按钮
    NSArray *loginImages = @[@"WeChatLoginIcon",@"phoneLoginIcon"];
    NSArray *loginTitles = @[@"微信一键登录",@"手机号登录"];
    NSInteger tempCount = loginImages.count;
    CGFloat btnWidth = (kScreenWidth - (55 + 65 + 85) * KWidth_ScaleW) / 2.0;
    CGFloat btnHeight = (40 + 17 + 18) * KWidth_ScaleH;
    for (NSInteger i = 0; i < tempCount; i++) {
        CustomLoginButtn *loginBtn = [[CustomLoginButtn alloc] initWithFrame:CGRectMake(55 * KWidth_ScaleW + (btnWidth + 85 * KWidth_ScaleW)  * i, 60 * KWidth_ScaleH, btnWidth, btnHeight)];
        [loginBtn setTheLoginImageView:loginImages[i]];
        [loginBtn setTheLoginTitleLabel:loginTitles[i]];
        loginBtn.tag = 50 + i;
        [loginBtn addTarget:self action:@selector(loginBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_bjImageView addSubview:loginBtn];
        loginBtn.hidden = YES;
        loginBtn.enabled = NO;
    }
    _loginStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _bjImageView.bounds.size.height - (13 + 22) * KWidth_ScaleH, 82 * KWidth_ScaleW, 22 * KWidth_ScaleH)];
    _loginStyleLabel.backgroundColor = [UIColor whiteColor];
    _loginStyleLabel.textAlignment = NSTextAlignmentCenter;
    _loginStyleLabel.textColor = UIColorFromRGBA(223, 48, 49, 1.0);
    _loginStyleLabel.layer.cornerRadius = 82 * KWidth_ScaleW / 8;
    _loginStyleLabel.clipsToBounds = YES;
    _loginStyleLabel.text = @"登录方式";
    _loginStyleLabel.font = [UIFont systemFontOfSize:13.f];
    [_bjImageView addSubview:_loginStyleLabel];
    _loginStyleLabel.centerX = _bjImageView.centerX;
    _loginStyleLabel.hidden = YES;
    
    self.tableView.tableHeaderView = _bjImageView;
    
    
    BOOL theLogin = [[KUserDefault objectForKey:IsLogin] boolValue];
    [self headerPortraitAndNameShow:theLogin];
}

- (void)wechatLoginPromptView{
    
    GWMultiGraphAlertView *multiGraphAlertView = [[GWMultiGraphAlertView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    multiGraphAlertView.alertVC = self;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:multiGraphAlertView];
}
-(UILabel *)cacheLabel{
    if (_cacheLabel == nil) {
        
        _cacheLabel = [[UILabel alloc] init];
        _cacheLabel.textColor = UIColorFromRGBA(87, 87, 87, 1.0);
        _cacheLabel.font = [UIFont systemFontOfSize:14.f];
        _cacheLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return _cacheLabel;
}
-(UITableView *)tableView{
    if (_tableView == nil) {
        
        CGRect tableView_frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 49);
        _tableView = [[UITableView alloc] initWithFrame:tableView_frame style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColorFromRGBA(245, 245, 245, 1);
        UIView *bgColorView = [[UIView alloc] initWithFrame:_tableView.frame];
        [self viewColorChangeFromCoror:UIColorFromRGBA(199, 9, 9, 1.0) toColor:UIColorFromRGBA(245, 245, 245, 1.0) withTheView:bgColorView];
        _tableView.backgroundView = bgColorView;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.scrollEnabled = NO;
    }
    
    return _tableView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat titleLabelHeight = 21 * KWidth_ScaleH;
    CGSize titleLabelWidthSize = [_titleLabel sizeThatFits:CGSizeMake(MAXFLOAT,titleLabelHeight)];
    _titleLabel.frame = CGRectMake(0, 0, titleLabelWidthSize.width, titleLabelHeight);
    _titleLabel.text = _nameLabel.text;
    [_titleLabel sizeToFit];
    _titleLabel.centerX = self.backView.centerX;
    _titleLabel.bottom = self.backView.bottom + 5;
    
    CGFloat offset_Y = scrollView.contentOffset.y;
//    CGFloat alpha = (offset_Y + 40)/300.0f;
    CGFloat alpha = (offset_Y)/300.0f;
    self.backView.backgroundColor = [self.backColor colorWithAlphaComponent:alpha];
    _titleLabel.textColor = UIColorFromRGBA(255, 255, 255, alpha);
    _nameLabel.hidden = YES;
    if (offset_Y == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            _titleLabel.textColor = UIColorFromRGBA(255, 255, 255, 0);
            _nameLabel.hidden = NO;
        }];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataLists.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *theArr = self.dataLists[section];
    return theArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"theCellCellId";
    MineCell *theCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (theCell == nil) {
        theCell = [[MineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    theCell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *cellAssistantIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    cellAssistantIcon.image = [UIImage imageNamed:@"MineAuxiliaryIcon"];
    theCell.accessoryView = cellAssistantIcon;
    NSArray *theArr = self.dataLists[indexPath.section];
    theCell.theDic = theArr[indexPath.row];
    
    return theCell;
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 1) {
            [cell.contentView addSubview:self.cacheLabel];
            [self.cacheLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(14);
                make.right.mas_equalTo(-16);
                make.top.mas_equalTo(15);
            }];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        UIView *gapView = [[UIView alloc] init];
        return gapView;
    }else{
        
        UIView *gapView = [[UIView alloc] init];
        gapView.backgroundColor = UIColorFromRGBA(245, 245, 245, 1);
        return gapView;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    lineView.backgroundColor = UIColorFromRGBA(214, 215, 220, 1.0);
    return lineView;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else{
        return 10;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.theIndexPath = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //先将未到时间执行前的任务取消。
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(todoSomething:) object:cell];
    [self performSelector:@selector(todoSomething:)withObject:cell afterDelay:0.2f];
    
}
#pragma mark -- method
- (void)todoSomething:(id)sender
{
    BOOL theLogin = [[KUserDefault objectForKey:IsLogin] boolValue];
    
    if (self.theIndexPath.section == 0) {
        if (self.theIndexPath.row == 0) {
            if (theLogin) {//收藏
                NSString *wapUrlStr = [NSString stringWithFormat:@"%@",self.collection_url];
                [self setUpSubviews:wapUrlStr withTitleName:@"我的收藏"];
            }else{
                [self wechatLoginPromptView];
            }
        }else {
            //清理缓存
            [self clearCache];
        }
    }else{//关于我们
        if (self.theIndexPath.row == 0) {
            NSString *wapUrlStr = [NSString stringWithFormat:@"%@",self.aboutus_url];
            [self setUpSubviews:wapUrlStr withTitleName:@"关于我们"];
        }else {
            //退出登录
            [self popSecondAlertViewWithTitle:@"您确定需要退出登录么？" Message:nil];
        }
    }
}
- (void)setUpSubviews:(NSString *)wapUrl withTitleName:(NSString *)titleName{
    
    
    webViewController *webVC = [[webViewController alloc] init];
    webVC.wap_url = wapUrl;
    webVC.titleNameStr = titleName;
    [self.navigationController pushViewController:webVC animated:YES];
}
- (void)logOut{

    [KUserDefault setObject:nil forKey:WX_OPEN_ID];
    [KUserDefault setObject:nil forKey:WX_ACCESS_TOKEN];
    [KUserDefault setObject:nil forKey:WX_REFRESH_TOKEN];
    [KUserDefault setObject:nil forKey:unionid];
    [KUserDefault setObject:nil forKey:nickname];
    [KUserDefault setObject:nil forKey:headimgurl];
    [KUserDefault setObject:@0 forKey:IsLogin];
    [KUserDefault synchronize];
    _headerPortraitImageView.clipsToBounds = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginResultNotification object:@"0"];
}
-(void)Cache
{
    SDWebImageManager *m = [SDWebImageManager sharedManager];
    CGFloat size = m.imageCache.getSize / (1024 * 1024.0);
    self.cacheLabel.text = [NSString stringWithFormat:@"%.1fM", size];
}
- (void)clearCache{

    // 真正的清空缓存
    [[SDWebImageManager sharedManager].imageCache clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];//可有可无
    [self Cache];
    [MBProgressHUD showSuccess:@"缓存已经清除!"];
}
- (void)headerPortraitAndNameShow:(BOOL)isShow{
    
    CustomLoginButtn *wechatLoginBtn = (CustomLoginButtn *)[_bjImageView viewWithTag:50];
    CustomLoginButtn *phoneLoginBtn = (CustomLoginButtn *)[_bjImageView viewWithTag:51];
    if (isShow) {
        _headerPortraitImageView.hidden = NO;
        _nameLabel.hidden = NO;
        _loginStyleLabel.hidden = YES;
        wechatLoginBtn.hidden = YES;
        phoneLoginBtn.hidden = YES;
        NSString *tempNickName = [KUserDefault objectForKey:nickname];
        NSString *tempHeadeImgUrl = [KUserDefault objectForKey:headimgurl];
        [_headerPortraitImageView sd_setImageWithURL:[NSURL URLWithString:tempHeadeImgUrl] placeholderImage:[UIImage imageNamed:@"DefaultUserHeadPotritIcon"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            _headerPortraitImageView.clipsToBounds = YES;
        }];
        _nameLabel.text = tempNickName;
    }else{
        _headerPortraitImageView.hidden = YES;
        _nameLabel.hidden = YES;
        _loginStyleLabel.hidden = NO;
        wechatLoginBtn.hidden = NO;
        wechatLoginBtn.enabled = YES;
        phoneLoginBtn.hidden = NO;
        phoneLoginBtn.enabled = YES;
    }
}
- (void)wechatLogin {
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"WuMingApp";
    if ([WXApi isWXAppInstalled]) {
        [WXApi sendReq:req];
    }
    else {
        //没安装微信调用
        [WXApi sendAuthReq:req viewController:self delegate:self];
//        [self setupAlertController];
    }
}

- (void)viewColorChangeFromCoror:(UIColor *)fromColor toColor:(UIColor *)toColor withTheView:(UIView *)view{
    
    //初始化CAGradientlayer对象，使它的大小为UIView的大小
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    
    //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
    [view.layer addSublayer:gradientLayer];
    
    //设置渐变区域的起始和终止位置（范围为0-1）
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 0.4);
    
    //设置颜色数组
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor,
                             (__bridge id)toColor.CGColor];
    
    //设置颜色分割点（范围：0-1）
    gradientLayer.locations = @[@(0.5f), @(1.0f)];
}
#pragma mark -- 按钮
- (void)loginBtn:(UIButton *)button{

    if (button.tag == 50) {
            //微信登录
        NSString *accessToken = [KUserDefault objectForKey:WX_ACCESS_TOKEN];
        NSString *openID = [KUserDefault objectForKey:WX_OPEN_ID];
        // 如果已经请求过微信授权登录，那么考虑用已经得到的access_token
        if (accessToken && openID) {
            
            NSString *refreshToken = [KUserDefault objectForKey:WX_REFRESH_TOKEN];
            NSString *refreshUrlStr = [NSString stringWithFormat:@"%@/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", WX_BASE_URL, WX_App_ID, refreshToken];
            [DataService getWechatWithURL:refreshUrlStr params:nil success:^(id responseObject) {
                NSLog(@"请求reAccess的response = %@", responseObject);
                NSDictionary *refreshDict = [NSDictionary dictionaryWithDictionary:responseObject];
                NSString *reAccessToken = [refreshDict objectForKey:WX_ACCESS_TOKEN];
                // 如果reAccessToken为空,说明reAccessToken也过期了,反之则没有过期
                if (reAccessToken) {
                    // 更新access_token、refresh_token、open_id
                    [KUserDefault setObject:reAccessToken forKey:WX_ACCESS_TOKEN];
                    [KUserDefault setObject:[refreshDict objectForKey:WX_OPEN_ID] forKey:WX_OPEN_ID];
                    [KUserDefault setObject:[refreshDict objectForKey:WX_REFRESH_TOKEN] forKey:WX_REFRESH_TOKEN];
                    [KUserDefault synchronize];
                    // 当存在reAccessToken不为空时直接执行AppDelegate中的wechatLoginByRequestForUserInfo方法
                    !self.requestForUserInfoBlock ? : self.requestForUserInfoBlock();
                }
                else {
                    [self wechatLogin];
                }
                
            } failure:^(NSError *error) {
                NSLog(@"用refresh_token来更新accessToken时出错 = %@", error);
            }];
        }
        else {
            [self wechatLogin];
        }
    }else{
            //手机号登录
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }


}
#pragma mark -- 手势
- (void)headerTapAction:(UITapGestureRecognizer *)tap{
    
    NSLog(@"点击了用户头像");
//    if (self.isLoginAndLogout) {
//    }else{
//        
//    }
}
#pragma mark -- 通知
- (void)loginSuccess:(NSNotification *)notify{
    NSString *theStr = notify.object;
    NSArray *datas = nil;
    if ([theStr isEqualToString:@"1"]) {
        //登录成功
        self.isLoginAndLogout = YES;
        datas = @[
                  @[@{@"image":[UIImage imageNamed:@"MyCollectionIcon"],@"title":@"我的收藏"},
                    @{@"image":[UIImage imageNamed:@"ClearCacheIcon"],@"title":@"清理缓存"}
                    ],
                  
                  @[@{@"image":[UIImage imageNamed:@"AboutUsIcon"],@"title":@"关于我们"},
                    @{@"image":[UIImage imageNamed:@"LogOutIcon"],@"title":@"退出登录"}]
                  ];
    }else{
        //退出登录
        self.isLoginAndLogout = NO;
        datas = @[
                  @[@{@"image":[UIImage imageNamed:@"MyCollectionIcon"],@"title":@"我的收藏"},
                    @{@"image":[UIImage imageNamed:@"ClearCacheIcon"],@"title":@"清理缓存"}
                    ],
                  
                  @[@{@"image":[UIImage imageNamed:@"AboutUsIcon"],@"title":@"关于我们"}]
                  ];
    }
    [self headerPortraitAndNameShow:self.isLoginAndLogout];
    self.dataLists = [datas mutableCopy];
    [self.tableView reloadData];
    
}
#pragma mark - 设置弹出提示语
- (void)setupAlertController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
}
//提示控件
- (void)popSecondAlertViewWithTitle:(NSString *)title Message:(NSString *)message{
    
    //弹出alert视图提示输入账号密码
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self logOut];
        
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dealloc
{
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
