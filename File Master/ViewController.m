//
//  ViewController.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewController.h"
#import "ShowTypePopViewController.h"
#import "LeftSlipManager.h"
#import "LeftViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "LSViewController.h"
#import "ESViewController.h"
#import "FViewController.h"
#import "HViewController.h"
#import "SViewController.h"
#import "PIViewController.h"

#define BLUECOLOR [UIColor colorWithDisplayP3Red:51/255.0 green:171/255.0 blue:238/255.0 alpha:1]

@interface ViewController () <ShowTypePopViewControllerDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate>
{
    UICollectionViewFlowLayout *flowlayout;
    CollectionViewController *collectionCtrl;
    UIBarButtonItem *editBtn;
    UIBarButtonItem *menuBtn;
    UIBarButtonItem *backBtn;
    UIBarButtonItem *deleteBtn;
    UIBarButtonItem *spaceItem;
    UIBarButtonItem *listBtn;
    UIBarButtonItem *searchBtn;
    UIBarButtonItem *addBtn;
    UIBarButtonItem *shareBtn;
    UIBarButtonItem *sortBtn;
    AppDelegate *appDelegate;
    BOOL isDirectoryFirst;//是否勾选目录优先
    BOOL isDesc;//是否升序
    NSInteger selectedSortType;//选择的排序方式:1:名称 2:大小 3:日期 4:类型
    NSMutableArray *dataArr;//页面原始数据
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.navigationController pushViewController:[[LoginViewController alloc] init] animated:NO];
    [self showMainView];
    [self initNavigationItems];
    [self initToolBar];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    isDirectoryFirst = false;
    isDesc = true;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    appDelegate.viewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 1];
    [collectionCtrl.collectionView reloadData];
}

#pragma mark - 初始化(主视图 导航栏 工具栏)
//根据文件路径初始化显示的数据
- (instancetype)initWithFile:(NSString*)path fileName: (NSString*)name {
    self = [super init];
    if (self) {
        if (path && name) {
            self.sourcePath = path;
            self.fileTitle = name;
        }
    }
    return self;
}

//初始化主视图
- (void)showMainView {
    flowlayout = [[UICollectionViewFlowLayout alloc] init];
    collectionCtrl = [[CollectionViewController alloc] initWithCollectionViewLayout:flowlayout];
    if (self.sourcePath) {
        [collectionCtrl initFilePath:self.sourcePath];
    } else {
//        NSString *homePath = NSHomeDirectory();
//        [collectionCtrl initFilePath:homePath];
        [collectionCtrl initFilePath:[NSString stringWithFormat:@"%@/Resource",[[NSBundle mainBundle] pathForResource:@"Resources" ofType:@"bundle"]]];
    }
    [self addChildViewController:collectionCtrl];
    [self.view addSubview:collectionCtrl.view];
    [[DYLeftSlipManager sharedManager] setLeftViewController:[LeftViewController new] coverViewController:self.navigationController];
    //页面原始数据
    dataArr = collectionCtrl.dataArr;
}

//初始化导航栏按钮
-(void)initNavigationItems {
    //去掉导航栏下面黑线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    //导航栏不透明
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    //导航栏按钮颜色
    self.navigationController.navigationBar.tintColor = BLUECOLOR;
    //导航栏标题
    if (self.fileTitle) {
        self.navigationItem.title = self.fileTitle;
    } else {
        self.navigationItem.title = @"主界面";
    }
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithDisplayP3Red:51/255.0 green:171/255.0 blue:238/255.0 alpha:1], NSForegroundColorAttributeName, nil]];
    //隐藏返回按钮
    [self.navigationItem setHidesBackButton:YES];
    //编辑按钮
    editBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(jumpToEditV)];
    self.navigationItem.rightBarButtonItem = editBtn;
    //菜单按钮
    menuBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"app-menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    //返回按钮
    backBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    if (self.sourcePath) {
        self.navigationItem.leftBarButtonItem = backBtn;
    } else {
        self.navigationItem.leftBarButtonItem = menuBtn;
    }
}

//初始化工具栏按钮
-(void)initToolBar {
    [self.navigationController setToolbarHidden:NO animated:YES];
    //工具栏按钮背景颜色
    self.navigationController.toolbar.barTintColor = [UIColor whiteColor];
    //工具栏按钮颜色
    self.navigationController.toolbar.tintColor = BLUECOLOR;
    spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //切换视图按钮
    listBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-list-normal"] style:UIBarButtonItemStylePlain target:self action:@selector(pop:)];
    listBtn.tag = 0;
    //查询按钮
    searchBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-search"] style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    //添加按钮
    addBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-add"] style:UIBarButtonItemStylePlain target:self action:nil];
    //排序按钮
    sortBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-sort"] style:UIBarButtonItemStylePlain target:self action:@selector(pop:)];
    sortBtn.tag = 1;
    //分享按钮
    shareBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-share"] style:UIBarButtonItemStylePlain target:self action:nil];
    [self setToolbarItems:@[listBtn, spaceItem, searchBtn, spaceItem, addBtn, spaceItem, sortBtn, spaceItem ,shareBtn]];
}

#pragma mark - 左侧菜单
//显示菜单
- (void)showMenu {
    [[DYLeftSlipManager sharedManager] menuClick];
}

//点击菜单进入相应的功能view
-(void)jumpToView:(NSInteger)selectedIndex {
    switch (selectedIndex) {
        //本地存储view
        case 0:
            [self.navigationController pushViewController:[[LSViewController alloc] init] animated:NO];
            break;
        //外部存储view
        case 1:
            [self.navigationController pushViewController:[[ESViewController alloc] init] animated:NO];
            break;
        //我的收藏夹view
        case 2:
            [self.navigationController pushViewController:[[FViewController alloc] init] animated:NO];
            break;
        //最近打开的文件view
        case 3:
            [self.navigationController pushViewController:[[HViewController alloc] init] animated:NO];
            break;
        //设置view
        case 4:
            [self.navigationController pushViewController:[[SViewController alloc] init] animated:NO];
            break;
        //产品信息view
        case 5:
            [self.navigationController pushViewController:[[PIViewController alloc] init] animated:NO];
            break;
        default:
            break;
    }
    //不是第一个视图时设置左拉手势返回上一个视图
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

#pragma mark - 编辑视图(全选 删除)
//跳转到编辑视图
- (void)jumpToEditV {
    collectionCtrl.isEditing = !collectionCtrl.isEditing;
    if (collectionCtrl.isEditing) {
        collectionCtrl.collectionView.allowsMultipleSelection = YES;
        [self initEditingView];
    } else {
        //编辑状态下全选完直接点击完成退出时将全选状态取消
        if (self.isSelectAll) {
            self.isSelectAll = !self.isSelectAll;
        }
        [self initNavigationItems];
        [self initToolBar];
        //退出编辑状态时清空选择的行数
        collectionCtrl.selectedNum = 0;
        //退出编辑状态时清空删除的数据
        [collectionCtrl.selectedArr removeAllObjects];
        collectionCtrl.collectionView.allowsMultipleSelection = NO;
        [collectionCtrl.collectionView  selectItemAtIndexPath:nil animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [collectionCtrl.collectionView reloadData];
    }
}

//初始化编辑状态下视图
-(void)initEditingView {
    [collectionCtrl.collectionView reloadData];
    //编辑状态下右侧编辑按钮变为完成
    [editBtn setTitle:@"完成"];
    self.navigationItem.title = @"选择项目";
    //左侧添加全选按钮
    self.selectAllBtn = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllBtn:)];
    self.navigationItem.leftBarButtonItem = self.selectAllBtn;
    //工具栏添加删除按钮
    deleteBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteData)];
    [self setToolbarItems:@[spaceItem, deleteBtn] animated:YES];
}

//全选
- (void)selectAllBtn:(id)sender {
    self.isSelectAll = !self.isSelectAll;
    if (self.isSelectAll) {
        //全选状态下左侧全选按钮变为取消
        [self.selectAllBtn setTitle:@"取消"];
        //改变选择的行数
        collectionCtrl.selectedNum = collectionCtrl.dataArr.count;
        self.navigationItem.title = [NSString stringWithFormat:@"已选择%@个项目",[[NSNumber numberWithLong:collectionCtrl.selectedNum] stringValue]];
        //cell全部变成选中状态
        for (int i = 0; i< collectionCtrl.dataArr.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [collectionCtrl.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        //点击全选的时候需要清除selectedArr里面的数据，防止原来的selectedArr里面有残留数据
        if (collectionCtrl.selectedArr.count >0) {
            [collectionCtrl.selectedArr removeAllObjects];
        }
        [collectionCtrl.selectedArr addObjectsFromArray:collectionCtrl.dataArr];
    } else {
        //退出列表模式下的编辑视图
        if (!collectionCtrl.isCell) {
            [collectionCtrl.collectionView reloadData];
        }
        //非全选状态下左侧取消按钮变为全选
        [self.selectAllBtn setTitle:@"全选"];
        self.navigationItem.title = @"选择项目";
        collectionCtrl.selectedNum = 0;
        //cell全部变成非选中状态
        [collectionCtrl.collectionView  selectItemAtIndexPath:nil animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [collectionCtrl.selectedArr removeAllObjects];
    }
}

//删除弹框
- (void)deleteData {
    if (collectionCtrl.selectedArr.count > 0) {
        NSString *i = [[NSString alloc] init];
        if (collectionCtrl.selectedArr.count == 1) {
            i = @"删除项目";
        } else {
            i = [NSString stringWithFormat:@"删除%ld个项目", (long)collectionCtrl.selectedNum];
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:i style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
            [self confirmDelete];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

//确认删除
- (void)confirmDelete {
    self.navigationItem.title = @"选择项目";
    collectionCtrl.selectedNum = 0;
    [collectionCtrl.dataArr removeObjectsInArray:collectionCtrl.selectedArr];
    [collectionCtrl.selectedArr removeAllObjects];
    [collectionCtrl.collectionView  selectItemAtIndexPath:nil animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [collectionCtrl.collectionView reloadData];
}

#pragma mark - 切换视图模式 排序
//弹出框
- (void)pop:(UIBarButtonItem*)btn {
    ShowTypePopViewController *popV = [[ShowTypePopViewController alloc] initWithPopView:btn isDirectoryFirst:(BOOL)isDirectoryFirst isDesc:(BOOL)isDesc selectedSortType:(NSInteger)selectedSortType];
    popV.delegate = self;
    [self presentViewController:popV animated:YES completion:nil];
}

//选择显示模式
- (void)chooseShowType:(ShowTypePopViewController *)controller didSelectAtIndex:(int)index btnTag:(int)btnTag isDirectoryFirst:(BOOL)isDF isDesc:(BOOL)isDc {
    isDirectoryFirst = isDF;
    isDesc = isDc;
    switch (btnTag) {
        //切换视图模式
        case 0:
            switch (index) {
                case 0:
                    collectionCtrl.isCell = NO;
                    [collectionCtrl.collectionView reloadData];
                    break;
                case 1:
                    collectionCtrl.isCell = YES;
                    [collectionCtrl.collectionView reloadData];
                    break;
                default:
                    break;
            }
            break;
        //排序
        case 1:
            if (index != 0) {
                selectedSortType = index;
            }
            [collectionCtrl sortByTypes:selectedSortType isDesc:isDesc isDirectoryFirst:isDirectoryFirst];
        default:
            break;
    }
}

#pragma mark - 搜索
//搜索
- (void)search {
    //页面原始数据
    dataArr = collectionCtrl.dataArr;
    //用来放searchBar的View
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    //创建searchBar
    CGRect frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, 40);
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:frame];
    //默认提示文字
    searchBar.placeholder = @"搜索内容";
    //代理
    searchBar.delegate = self;
    //显示右侧取消按钮
    searchBar.showsCancelButton = YES;
    //光标颜色
    searchBar.tintColor = BLUECOLOR;
    //拿到searchBar的输入框
    UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    //字体大小
    searchField.font = [UIFont systemFontOfSize:15];
    searchField.textColor = BLUECOLOR;
    //取消按钮
    UIButton *cancleBtn = [searchBar valueForKey:@"cancelButton"];
    [cancleBtn addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    //设置按钮上的文字
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    //设置按钮上文字的颜色
    [cancleBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    //iOS 11异常处理
    if(@available(iOS 11.0, *)) {
        [[searchBar.heightAnchor constraintEqualToConstant:44] setActive:YES];
    }
    self.navigationItem.titleView = searchBar;
    //弹出键盘
    [searchBar becomeFirstResponder];
    //取消其他pop弹窗
    [self dismissViewControllerAnimated:NO completion:nil];
}

//取消搜索
- (void)cancelSearch {
    self.navigationItem.titleView = nil;
    if (self.sourcePath) {
        self.navigationItem.leftBarButtonItem = backBtn;
    } else {
        self.navigationItem.leftBarButtonItem = menuBtn;
    }
    self.navigationItem.rightBarButtonItem = editBtn;
    collectionCtrl.dataArr = dataArr;
    [collectionCtrl.collectionView reloadData];
}

#pragma mark - UISearchBarDelegate
//搜索内容改变时触发
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *resultArr = [NSMutableArray array];
    if (dataArr) {
        if (!searchText.length) {
            resultArr = dataArr;
        } else {
            for (int i = 0; i< dataArr.count; i++){
                NSString *str = dataArr[i][@"name"];
                if ([str.lowercaseString containsString:searchText.lowercaseString]) {
                    [resultArr addObject:dataArr[i]];
                }
            }
        }
    }
    collectionCtrl.dataArr = resultArr;
    [collectionCtrl.collectionView reloadData];
}

//键盘点击search收起键盘
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - 目录操作(进入下级目录 返回上级目录)
//进入文件夹
- (void)enterFolder: (NSString*)path fileName: (NSString*)name {
    ViewController *viewCtrl = [[ViewController alloc] initWithFile:path fileName:name];
    appDelegate.viewController = viewCtrl;
    [self.navigationController pushViewController:viewCtrl animated:YES];
    //不是第一个视图时设置左拉手势返回上一个视图
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

//左拉手势返回上一个视图后执行
- (void)viewWillDisappear:(BOOL) animated {
    //切换视图时退出编辑状态
    if (collectionCtrl.isEditing) {
        [self jumpToEditV];
    }
    //切换视图时退出搜索状态
    [self cancelSearch];
}

//返回上级菜单
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
