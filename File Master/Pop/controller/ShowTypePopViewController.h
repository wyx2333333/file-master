//
//  ShowTypePopViewController.h
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShowTypePopViewController;

@protocol ShowTypePopViewControllerDelegate<NSObject>

- (void)chooseShowType:(ShowTypePopViewController*)controller didSelectAtIndex:(int)index btnTag:(int)tag isDirectoryFirst:(BOOL)isDirectoryFirst isDesc:(BOOL)isDesc;

@end

@interface ShowTypePopViewController : UITableViewController

@property (nonatomic, assign) id<ShowTypePopViewControllerDelegate> delegate;

/**
 *    @brief    根据点击的按钮初始化弹出框
 *    @param     btn (btn.tag = 0:切换视图模式弹出框 btn.tag = 1:排序弹出框)
 *    @param     isDirectoryFirst 是否目录优先
 *    @param     isDesc 是否降序
 *    @param     selectedSortType 选择的排序方式(1:名称 2:大小 3:日期 4:类型)
 */
- (instancetype)initWithPopView:(UIBarButtonItem*)btn isDirectoryFirst:(BOOL)isDirectoryFirst isDesc:(BOOL)isDesc selectedSortType:(NSInteger)selectedSortType;

@end
