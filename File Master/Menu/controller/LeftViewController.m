//
//  LeftViewController.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "LeftViewController.h"
#import "LeftViewTableViewCell.h"
#import "LeftSlipManager.h"
#import "LoginViewController.h"
#import "AppDelegate.h"

#define VIEW_WIDTH self.view.frame.size.width * 0.8
#define VIEW_HEIGHT self.view.frame.size.height
#define HEADVIEW_HEIGHT (VIEW_HEIGHT - CELL_HEIGHT * CELL_NUM) / 2
#define CELL_HEIGHT 50
#define CELL_NUM 6
#define MARGIN_LEFT 20 //cell中label内容距左边的margin

@interface LeftViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
{
    UITableView *tableview;
    LeftViewTableViewCell *cell;
    NSArray *labelName;//cell中label内容
    NSArray *labelIcoName;//cell中label旁icon名
    UIImageView *labelIco;//cell中label旁icon
    UIView *li;//分割线
    UIView *headView;//头像区域
    UIImageView *headImg;//头像图片
    UITextField *headName;//名称
    BOOL isCamera;//判断拍照设备
    AppDelegate *appDelegate;
}

@end

@implementation LeftViewController

- (void)viewDidLoad {
    //设置背景
    UIImage *bg_image = [UIImage imageNamed:@"sidebar_bg"];
    self.view.layer.contents = (id)bg_image.CGImage;
    //初始化tableView,并给tableView设置frame以及样式
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADVIEW_HEIGHT, VIEW_WIDTH, 400) style:UITableViewStylePlain];
    labelName = @[@"本地存储", @"外部存储", @"我的收藏夹" ,@"最近打开的文件", @"设置", @"关于"];
    labelIcoName = @[@"folder", @"link", @"favorite" ,@"history", @"set", @"information"];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.scrollEnabled = NO;
    tableview.backgroundColor = [UIColor clearColor];
    tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //隐藏分割线
    [tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableview];
    [self initHeadView];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

//初始化上方head区域
- (void)initHeadView {
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, HEADVIEW_HEIGHT)];
    [self.view addSubview:headView];
    headImg = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN_LEFT, headView.frame.size.height / 3,  headView.frame.size.height / 3,  headView.frame.size.height / 3)];
    //把头像设置成圆形
    headImg.layer.cornerRadius = headImg.frame.size.width / 2;//裁成圆角
    headImg.clipsToBounds = YES;//隐藏裁剪掉的部分
    //给头像加一个圆形边框
    headImg.layer.borderWidth = 1.5f;//宽度
    headImg.layer.borderColor = [UIColor whiteColor].CGColor;//颜色
    NSString *imgPath = [NSString stringWithFormat:@"%@/Documents/%@.png", NSHomeDirectory(), @"headIcon"];
    //拿到沙盒路径图片
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:imgPath];
    if (img != nil) {
        headImg.image = img;
    } else {
        headImg.image = [UIImage imageNamed:@"headImg"];
    }
    [headView addSubview:headImg];
    //允许用户交互
    headImg.userInteractionEnabled = YES;
    //初始化一个手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alterHeadPortrait:)];
    //给ImageView添加手势
    [headImg addGestureRecognizer:singleTap];
    headName = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT * 2 + headImg.frame.size.width, headImg.frame.origin.y, VIEW_WIDTH - MARGIN_LEFT * 3 - headImg.frame.size.width, headImg.frame.size.height)];
    NSString *headNamePath = [NSString stringWithFormat:@"%@/Documents/%@.txt", NSHomeDirectory(), @"headName"];
    //拿到沙盒路径图片
    NSString *name = [NSString stringWithContentsOfFile:headNamePath encoding:NSUTF8StringEncoding error:nil];
    if (name.length) {
        headName.text = name;
    } else {
        headName.text = @"Tom and Jerry";
    }
    headName.textColor = [UIColor whiteColor];
    [headName setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    headName.delegate = self;
    headName.returnKeyType = UIReturnKeyDone;
    [headView addSubview:headName];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
    [headName resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *path = NSHomeDirectory();
    //设置一个headName的存储路径
    NSString *headNamePath = [path stringByAppendingString:@"/Documents/headName.txt"];
    //把headName直接保存到指定的路径
    [headName.text writeToFile:headNamePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

//点击空白处收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//修改头像提示框
-(void)alterHeadPortrait:(UITapGestureRecognizer *)gesture {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self->isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (!self->isCamera) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的设备不支持拍照" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction: [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            return ;
        }else{
            UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
            //获取方式:通过相机
            PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
            PickerImage.allowsEditing = YES;
            PickerImage.delegate = self;
            [self presentViewController:PickerImage animated:YES completion:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        //通过相册（呈现全部相册）:UIImagePickerControllerSourceTypePhotoLibrary
        //通过相机:UIImagePickerControllerSourceTypeCamera
        //通过相册（呈现全部图片）:UIImagePickerControllerSourceTypeSavedPhotosAlbum
        PickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //允许编辑，即放大裁剪
        PickerImage.allowsEditing = YES;
        PickerImage.delegate = self;
        //页面跳转
        [self presentViewController:PickerImage animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

//PickerImage完成后的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //定义一个newPhoto，用来存放我们选择的图片。
    UIImage *newHeadImg = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    headImg.image = newHeadImg;
    NSString *path = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path stringByAppendingString:@"/Documents/headIcon.png"];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(newHeadImg) writeToFile:imagePath atomically:YES];
    [[self getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
}

//PickerImage取消的代理方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[self getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
}

//获取当前屏幕显示的ViewController
- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CELL_NUM;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = (LeftViewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"leftview"];
    if (cell == nil) {
        cell= (LeftViewTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"LeftViewTableViewCell" owner:self options:nil] lastObject];
    }
    cell.labelName.text = labelName[[indexPath row]];
    labelIco = [[UIImageView alloc] initWithFrame:CGRectMake(25, [tableview rectForRowAtIndexPath:indexPath].origin.y + 15, 20, 20)];
    labelIco.image = [UIImage imageNamed:labelIcoName[[indexPath row]]];
    [tableview addSubview:labelIco];
    if ([indexPath row] == 2 || [indexPath row] == 4) {
        li = [[UIView alloc] initWithFrame:CGRectMake(0, [tableview rectForRowAtIndexPath:indexPath].origin.y, self.view.frame.size.width, 0.5)];
        li.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.8];
        [tableview addSubview:li];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[DYLeftSlipManager sharedManager] menuClick];
    //点击菜单进入相应的功能view
    [appDelegate.viewController jumpToView:[indexPath row]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // cell.contents = (__bridge id)[UIImage imageNamed:@"47b5e3384e311b4f.jpg"].CGImage;
//    self.view.backgroundColor = [UIColor whiteColor];
//    // =================== 背景图片 ===========================
//    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    backgroundView.image = [UIImage imageNamed:@"樱花树"];
//    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
//    [self.view addSubview:backgroundView];
//    // =================== 樱花飘落 ====================
//    CAEmitterLayer * snowEmitterLayer = [CAEmitterLayer layer];
//    snowEmitterLayer.emitterPosition = CGPointMake(100, -30);
//    snowEmitterLayer.emitterSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
//    snowEmitterLayer.emitterMode = kCAEmitterLayerOutline;
//    snowEmitterLayer.emitterShape = kCAEmitterLayerLine;
//    // snowEmitterLayer.renderMode = kCAEmitterLayerAdditive;
//    CAEmitterCell * snowCell = [CAEmitterCell emitterCell];
//    snowCell.contents = (__bridge id)[UIImage imageNamed:@"樱花瓣"].CGImage;
//
//    // 花瓣缩放比例
//    snowCell.scale = 0.02;
//    snowCell.scaleRange = 0.5;
//
//    // 每秒产生的花瓣数量
//    snowCell.birthRate = 7;
//    snowCell.lifetime = 80;
//
//    // 每秒花瓣变透明的速度
//    snowCell.alphaSpeed = -0.01;
//
//    // 秒速“五”厘米～～
//    snowCell.velocity = 40;
//    snowCell.velocityRange = 60;
//
//    // 花瓣掉落的角度范围
//    snowCell.emissionRange = M_PI;
//
//    // 花瓣旋转的速度
//    snowCell.spin = M_PI_4;
//
//    // 每个cell的颜色
//    // snowCell.color = [[UIColor redColor] CGColor];
//
//    // 阴影的不透明度
//    snowEmitterLayer.shadowOpacity = 1;
//    // 阴影化开的程度（就像墨水滴在宣纸上化开那样）
//    snowEmitterLayer.shadowRadius = 8;
//    // 阴影的偏移量
//    snowEmitterLayer.shadowOffset = CGSizeMake(3, 3);
//    // 阴影的颜色
//    snowEmitterLayer.shadowColor = [[UIColor whiteColor] CGColor];
//    snowEmitterLayer.emitterCells = [NSArray arrayWithObject:snowCell];
//    [backgroundView.layer addSublayer:snowEmitterLayer];
//}

@end
