//
//  ViewController.h
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic ,strong) UIBarButtonItem *selectAllBtn;//全选按钮

@property (nonatomic ,assign) BOOL isSelectAll;//是否全选

@property (nonatomic ,strong) NSString *sourcePath;//资源路径

@property (nonatomic ,strong) NSString *fileTitle;//文件夹名称

@property (nonatomic, strong) UISearchBar *searchBar;//搜索框

- (instancetype)initWithFile:(NSString*)path fileName: (NSString*)name;//初始化文件夹内内容

- (void)enterFolder: (NSString*)path fileName: (NSString*)name;//进入文件夹

- (void)jumpToView: (NSInteger)selectedIndex;//点击菜单进入相应的功能view

@end

