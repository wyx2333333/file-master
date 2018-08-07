//
//  ShowTypePopViewController.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "ShowTypePopViewController.h"
#import "PopViewCell.h"

#define BLUECOLOR [UIColor colorWithDisplayP3Red:51/255.0 green:171/255.0 blue:238/255.0 alpha:1]
#define TABLE_WIDTH 110
#define TABLE_HEIGHT 36

@interface ShowTypePopViewController ()<UIPopoverPresentationControllerDelegate> {
    NSArray *imageArr;
    NSArray *textArr;
    NSInteger btnTag;
    NSInteger selectedNum;//选择的排序方式:1:名称 2:大小 3:日期 4:类型
    BOOL isDirectoryFirst;//是否勾选目录优先
    BOOL isDesc;//是否降序
}

@end

@implementation ShowTypePopViewController

//初始化
- (instancetype)initWithPopView:(UIBarButtonItem*)btn isDirectoryFirst:(BOOL)isDF isDesc:(BOOL)isDsc selectedSortType:(NSInteger)selectedSortType {
    if (self = [super init]) {
        btnTag = btn.tag;
        isDirectoryFirst = isDF;
        isDesc = isDsc;
        selectedNum = selectedSortType;
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.barButtonItem = btn;
        self.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        //btn.tag
        //0:切换视图模式
        //1:排序
        switch (btnTag) {
            case 0:
                imageArr = @[@"button-list-detail", @"button-grid"];
                textArr = @[@"列表模式", @"网格模式"];
                break;
            case 1:
                textArr = @[@"目录优先",@"名称排序", @"大小排序", @"日期排序", @"类型排序"];
                break;
            default:
                break;
        }
        self.preferredContentSize = CGSizeMake(TABLE_WIDTH, TABLE_HEIGHT * textArr.count);
        self.popoverPresentationController.backgroundColor = [UIColor whiteColor];
        self.popoverPresentationController.delegate =self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    //初始化tableView,并给tableView设置frame以及样式
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    //遵守代理和数据源(因为要用到代理和数据源方法)
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //禁止滚动
    self.tableView.scrollEnabled = NO;
    //隐藏分割线
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerNib:[UINib nibWithNibName:@"PopViewCell" bundle:nil] forCellReuseIdentifier:@"PopCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return textArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopCell" forIndexPath:indexPath];
    //显示不同视图
    switch (btnTag) {
        case 0:
            cell.popImage.image = [UIImage imageNamed:imageArr[[indexPath row]]];
            break;
        case 1:
            //勾选目录优先
            if ([indexPath row] == 0) {
                if (isDirectoryFirst) {
                    [cell.popLabel setFrame:CGRectMake(15, 7, 62, 22)];
                    [cell.popImage setFrame:CGRectMake(82, 9, 18, 18)];
                    cell.popImage.image = [UIImage imageNamed:@"selected"];
                } else {
                    [cell.popLabel setFrame:CGRectMake(24, 7, 62, 22)];
                    [cell.popImage setFrame:CGRectZero];
                }
            } else {
                //选中排序方式的cell修改样式
                if ([indexPath row] == selectedNum) {
                    [cell.popLabel setFrame:CGRectMake(15, 7, 62, 22)];
                    [cell.popImage setFrame:CGRectMake(82, 9, 18, 18)];
                    if (isDesc) {
                        cell.popImage.image = [UIImage imageNamed:@"sort-down"];
                    } else {
                        cell.popImage.image = [UIImage imageNamed:@"sort-up"];
                    }
                } else {
                    [cell.popLabel setFrame:CGRectMake(24, 7, 62, 22)];
                    [cell.popImage setFrame:CGRectZero];
                }
            }
            [cell.popLabel setTextAlignment:NSTextAlignmentCenter];
            break;
        default:
            break;
    }
    [cell.popImage setTintColor:BLUECOLOR];
    cell.popLabel.text = textArr[[indexPath row]];
    if ([indexPath row] != 0) {
        UIView *li = [[UIView alloc] initWithFrame:CGRectMake(10, [self.tableView rectForRowAtIndexPath:indexPath].origin.y, TABLE_WIDTH - 20, 0.5)];
        li.backgroundColor = BLUECOLOR;
        [self.tableView addSubview:li];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (btnTag == 1) {
        if ([indexPath row] == 0) {
            //勾选目录优先
            isDirectoryFirst = !isDirectoryFirst;
        } else {
            //点击升降序切换(第一次点击为升序)
            isDesc = !isDesc;
            if ([indexPath row] != selectedNum) {
                isDesc = true;
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(chooseShowType:didSelectAtIndex:btnTag:isDirectoryFirst:isDesc:)]) {
        [self.delegate chooseShowType:self didSelectAtIndex:(int)indexPath.row btnTag:(int)btnTag isDirectoryFirst:(BOOL)isDirectoryFirst isDesc:(BOOL)isDesc];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    //此处为不适配(如果选择其他,会自动视频屏幕,上面设置的大小就毫无意义了)
    return UIModalPresentationNone;
}

@end

