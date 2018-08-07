//
//  CollectionViewController.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "DataModel.h"
#import "AppDelegate.h"
#import "CellModel.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#define MP3 "ico_small_mp3"
#define MP4 "ico_small_mov"
#define FOLDER "ico_small_folder"

@interface CollectionViewController () <UICollectionViewDelegateFlowLayout, UIDocumentInteractionControllerDelegate>

{
    DataModel *dataModel;
    AppDelegate *appDelegate;
    CellModel *model;
    UICollectionViewFlowLayout *flowlayout;
}

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"CollectionViewCell";

#pragma mark - Getters

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)selectedArr {
    if (!_selectedArr) {
        _selectedArr = [NSMutableArray array];
    }
    return _selectedArr;
}

-(void)initFilePath: (NSString*)path {
    if (path) {
        self.filePath = path;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    //默认表格视图
    self.isCell = NO;
    flowlayout = [[UICollectionViewFlowLayout alloc] init];
    //设置滚动方向
    [flowlayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowlayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

//初始化数据
- (void)initData {
    self.isEditing = NO;
    self.selectedNum = 0;
    dataModel = [[DataModel alloc] initWithPath:self.filePath];
    model = [[CellModel alloc] init];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (dataModel.dataSource) {
        for (int i = 0; i< dataModel.dataSource.count; i++){
            [self.dataArr addObject:dataModel.dataSource[i]];
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    //实例化cell数据
    [model setData:self.dataArr[[indexPath row]][@"iconName"] name:self.dataArr[[indexPath row]][@"name"] createTime:self.dataArr[[indexPath row]][@"time"] size:self.dataArr[[indexPath row]][@"size"]];
    cell.model = model;
    //根据展示的type不同，改变元素布局
    cell.isCell = self.isCell;
    cell.isEditing = self.isEditing;
    cell.backgroundColor = [UIColor whiteColor];
    if (self.isCell) {
        //左右间距
        flowlayout.minimumInteritemSpacing = 2;
        //上下间距
        flowlayout.minimumLineSpacing = 2;
    } else {
        flowlayout.minimumInteritemSpacing = 2;
        flowlayout.minimumLineSpacing = 2;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据展示的type不同，改变item大小
    if (self.isCell) {
        return CGSizeMake(([UIScreen mainScreen].bounds.size.width - 6) / 4, ([UIScreen mainScreen].bounds.size.width - 6) / 4);
    } else {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width - 4, 80);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //根据展示的type不同，改变item之间的间距大小(上左下右)
    if (self.isCell) {
        return UIEdgeInsetsMake(2, 0, 2, 0);
    } else {
        return UIEdgeInsetsMake(2, 0, 2, 0);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        self.selectedNum++;
        if (self.selectedNum == self.dataArr.count) {
            [appDelegate.viewController.selectAllBtn setTitle:@"取消"];
            appDelegate.viewController.isSelectAll = YES;
        }
        [self.selectedArr addObject:[self.dataArr objectAtIndex:indexPath.row]];
        if (self.selectedNum == 0) {
            appDelegate.viewController.title = @"选择项目";
        } else {
            appDelegate.viewController.title = [NSString stringWithFormat:@"已选择%ld个项目",(long)self.selectedNum];
        }
    } else {
        //点击打开文件
        NSURL *url = [NSURL fileURLWithPath:self.dataArr[[indexPath row]][@"path"]];
        //打开文件夹
        if ([self.dataArr[[indexPath row]][@"iconName"] isEqualToString:@FOLDER]) {
            [appDelegate.viewController enterFolder:self.dataArr[[indexPath row]][@"path"] fileName:self.dataArr[[indexPath row]][@"name"]];
            return;
        }
        if ([self.dataArr[[indexPath row]][@"iconName"] isEqualToString:@MP3] || [self.dataArr[[indexPath row]][@"iconName"] isEqualToString:@MP4]) {
                // 创建播放控制器
                AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                playerViewController.player = [AVPlayer playerWithURL:url];
                //可播放可录音，更可以后台播放，还可以在其他程序播放的情况下暂停播放(自动判断耳机或公放)
                AVAudioSession *session = [AVAudioSession sharedInstance];
                [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
                // 弹出播放页面
                [self presentViewController:playerViewController animated:YES completion:^{
                // 开始播放
                [playerViewController.player play];
            }];
        }
        if (self.documentVC == nil){
            self.documentVC = [UIDocumentInteractionController interactionControllerWithURL:url];
            self.documentVC.delegate = self;
        } else {
            self.documentVC.URL = url;
        }
        //预置预览功能
        BOOL b = [self.documentVC presentPreviewAnimated:YES];
        //无法预览
        if (b == NO) {
            BOOL result = [self.documentVC presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
            if (!result) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"没有找到可以打开该文件的应用" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing) {
        self.selectedNum--;
        [appDelegate.viewController.selectAllBtn setTitle:@"全选"];
        appDelegate.viewController.isSelectAll = NO;
        [self.selectedArr removeObject:[self.dataArr objectAtIndex:indexPath.row]];
        if (self.selectedNum == 0) {
            appDelegate.viewController.title = @"选择项目";
        } else {
            appDelegate.viewController.title = [NSString stringWithFormat:@"已选择%ld个项目",(long)self.selectedNum];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark <UIDocumentInteractionControllerDelegate>
//为快速预览指定控制器
- (UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController*)controller {
    return self;
}

//为快速预览指定View
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller {
    return self.view;
}

//为快速预览指定显示范围
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller {
    return self.view.bounds;
}

- (void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller{
    //NSLog(@"will begin preview");
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller{
    //NSLog(@"did end preview");
}

#pragma mark 排序
- (void)sortByTypes:(NSInteger)selectedSortType isDesc:(BOOL)isDesc isDirectoryFirst:(BOOL)isDirectoryFirst {
    NSSortDescriptor *prioritySD = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];//YES代表升序，NO代表降序
    NSSortDescriptor *nameSD = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:!isDesc];
    NSSortDescriptor *sizeSD = [NSSortDescriptor sortDescriptorWithKey:@"noTransformedSize" ascending:!isDesc];
    NSSortDescriptor *timeSD = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:!isDesc];
    NSSortDescriptor *typeSD = [NSSortDescriptor sortDescriptorWithKey:@"iconName" ascending:!isDesc];
    //排序方式
    switch (selectedSortType) {
        //勾选目录优先
        case 0:
            if (isDirectoryFirst) {
                [self.dataArr sortUsingDescriptors:@[prioritySD]];
            } else {
                [self.dataArr sortUsingDescriptors:@[]];
            }
            break;
        //按名称排序
        case 1:
            if (isDirectoryFirst) {
                [self.dataArr sortUsingDescriptors:@[prioritySD, nameSD]];
            } else {
                [self.dataArr sortUsingDescriptors:@[nameSD]];
            }
            break;
        //按大小排序
        case 2:
            if (isDirectoryFirst) {
                [self.dataArr sortUsingDescriptors:@[prioritySD, sizeSD]];
            } else {
                [self.dataArr sortUsingDescriptors:@[sizeSD]];
            }
            break;
        //按日期排序
        case 3:
            if (isDirectoryFirst) {
                [self.dataArr sortUsingDescriptors:@[prioritySD, timeSD]];
            } else {
                [self.dataArr sortUsingDescriptors:@[timeSD]];
            }
            break;
        //按类型排序
        case 4:
            if (isDirectoryFirst) {
                [self.dataArr sortUsingDescriptors:@[prioritySD, typeSD]];
            } else {
                [self.dataArr sortUsingDescriptors:@[typeSD]];
            }
            break;
        default:
            break;
    }
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
