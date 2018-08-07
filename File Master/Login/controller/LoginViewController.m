//
//  LoginViewController.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginTableViewCell.h"

#define SCREEN_WIDTH self.view.bounds.size.width
#define SCREEN_HEIGHT self.view.bounds.size.height
#define BLUECOLOR [UIColor colorWithDisplayP3Red:51/255.0 green:171/255.0 blue:238/255.0 alpha:1]
#define LIGHT_BLUECOLOR [UIColor colorWithDisplayP3Red:51/255.0 green:171/255.0 blue:238/255.0 alpha:0.5]

@interface LoginViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UITableView *tableview;
    LoginTableViewCell *cell;
    NSArray *imgData;
    NSArray *placeholderData;
    UIBarButtonItem *registerBartn;
    UILabel *forgetPwd;
    UIButton *loginBtn;
    UIButton *registerBtn;
    UIView *li1;
    UIView *li2;
    UILabel *otherLogin;
    UIImageView *qqLogo;
    UIImageView *weixinLogo;
    UIImageView *weiboLogo;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [self initNavigation];
    [self initTableView];
    [self initBtn];
    [self initOtherLoginView];
    [self initBackgroundView];
}

- (void)initNavigation {
    //去除导航栏下黑线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //导航栏不透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationItem.title = @"登陆";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:BLUECOLOR, NSForegroundColorAttributeName, nil]];
    //导航栏按钮颜色
    self.navigationController.navigationBar.tintColor = BLUECOLOR;
    //隐藏返回按钮
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController setToolbarHidden:YES animated:NO];
    //注册按钮
    registerBartn = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = registerBartn;
}

//登陆注册按钮
- (void)initBtn {
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 380) / 2, tableview.frame.origin.y + 240, 380, 45)];
    [loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
    [loginBtn setBackgroundColor: BLUECOLOR];
    loginBtn.layer.cornerRadius = 22;
    [self.view addSubview:loginBtn];
    registerBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 380) / 2, loginBtn.frame.origin.y + 80, 380, 45)];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    registerBtn.layer.borderWidth = 1;
    registerBtn.layer.cornerRadius = 22;
    registerBtn.layer.borderColor = BLUECOLOR.CGColor;
    [self.view addSubview:registerBtn];
}

//下方第三方登录视图
- (void)initOtherLoginView {
    //左侧横线
    li1 = [[UIView alloc] initWithFrame:CGRectMake(40, registerBtn.frame.origin.y + 155, 110, 1)];
    li1.backgroundColor = LIGHT_BLUECOLOR;
    [self.view addSubview:li1];
    //右侧横线
    li2 = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - li1.frame.origin.x - li1.frame.size.width, li1.frame.origin.y, li1.bounds.size.width, 1)];
    li2.backgroundColor = LIGHT_BLUECOLOR;
    [self.view addSubview:li2];
    //中间文字
    otherLogin = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 34, li1.frame.origin.y - 10, 68, 21)];
    otherLogin.text = @"第三方登录";
    [otherLogin setTextColor:LIGHT_BLUECOLOR];
    otherLogin.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:otherLogin];
    //第三方登录logo
    qqLogo = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 144)/4, li1.frame.origin.y + 50, 48, 48)];
    qqLogo.image = [UIImage imageNamed:@"qq"];
    [self.view addSubview:qqLogo];
    weixinLogo = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 24, qqLogo.frame.origin.y, 48, 48)];
    weixinLogo.image = [UIImage imageNamed:@"weixin"];
    [self.view addSubview:weixinLogo];
    weiboLogo = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 144)*3/4 + 96, qqLogo.frame.origin.y, 48, 48)];
    weiboLogo.image = [UIImage imageNamed:@"weibo"];
    [self.view addSubview:weiboLogo];
}

//中间用户名密码视图
- (void)initTableView {
    tableview = [[UITableView alloc]initWithFrame:CGRectMake(10, 100, SCREEN_WIDTH - 20, 140) style:UITableViewStylePlain];
    forgetPwd = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, tableview.frame.origin.y + 150, 60, 21)];
    forgetPwd.text = @"忘记密码?";
    [forgetPwd setTextColor:BLUECOLOR];
    forgetPwd.font = [UIFont systemFontOfSize:13];
    //添加下划线
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:@"忘记密码?" attributes:attribtDic];
    //赋值
    forgetPwd.attributedText = attribtStr;
    [self.view addSubview:forgetPwd];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.backgroundColor = [UIColor clearColor];
    tableview.layer.borderWidth = 2;
    tableview.layer.borderColor = BLUECOLOR.CGColor;
    tableview.layer.cornerRadius = 10;
    //top left bottom right(分割线边距)
    tableview.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    tableview.scrollEnabled = NO;
    [tableview setSeparatorColor:BLUECOLOR];
    imgData = @[@"account",@"pwd"];
    placeholderData = @[@"请输入手机号",@"请输入密码"];
    [self.view addSubview:tableview];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = (LoginTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"login"];
    if (cell == nil) {
        cell= (LoginTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"LoginTableViewCell" owner:self options:nil] lastObject];
    }
    cell.loginIcon.image = [UIImage imageNamed:imgData[[indexPath row]]];
    cell.loginInput.placeholder = placeholderData[[indexPath row]];
    //placeholder颜色
    [cell.loginInput setValue:LIGHT_BLUECOLOR forKeyPath:@"_placeholderLabel.textColor"];
    //密码点号处理
    if ([indexPath row] == 1) {
        cell.loginInput.secureTextEntry = YES;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)initBackgroundView {
    self.view.backgroundColor = [UIColor whiteColor];
    // =================== 背景图片 ===========================
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backgroundView.image = [UIImage imageNamed:@"樱花树"];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundView];
    // 将视图调整到最后面
    [self.view sendSubviewToBack:backgroundView];
    // =================== 樱花飘落 ====================
    CAEmitterLayer * snowEmitterLayer = [CAEmitterLayer layer];
    snowEmitterLayer.emitterPosition = CGPointMake(100, -30);
    snowEmitterLayer.emitterSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
    snowEmitterLayer.emitterMode = kCAEmitterLayerOutline;
    snowEmitterLayer.emitterShape = kCAEmitterLayerLine;
    // snowEmitterLayer.renderMode = kCAEmitterLayerAdditive;
    CAEmitterCell * snowCell = [CAEmitterCell emitterCell];
    snowCell.contents = (__bridge id)[UIImage imageNamed:@"樱花瓣"].CGImage;
    // 花瓣缩放比例
    snowCell.scale = 0.02;
    snowCell.scaleRange = 0.5;
    // 每秒产生的花瓣数量
    snowCell.birthRate = 7;
    snowCell.lifetime = 80;
    // 每秒花瓣变透明的速度
    snowCell.alphaSpeed = -0.01;
    // 秒速“五”厘米～～
    snowCell.velocity = 40;
    snowCell.velocityRange = 60;
    // 花瓣掉落的角度范围
    snowCell.emissionRange = M_PI;
    // 花瓣旋转的速度
    snowCell.spin = M_PI_4;
    // 每个cell的颜色
    // snowCell.color = [[UIColor redColor] CGColor];
    // 阴影的不透明度
    snowEmitterLayer.shadowOpacity = 1;
    // 阴影化开的程度（就像墨水滴在宣纸上化开那样）
    snowEmitterLayer.shadowRadius = 8;
    // 阴影的偏移量
    snowEmitterLayer.shadowOffset = CGSizeMake(3, 3);
    // 阴影的颜色
    snowEmitterLayer.shadowColor = [[UIColor whiteColor] CGColor];
    snowEmitterLayer.emitterCells = [NSArray arrayWithObject:snowCell];
    [backgroundView.layer addSublayer:snowEmitterLayer];
    backgroundView.alpha = 0.2f;
}

// 点击空白处收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
