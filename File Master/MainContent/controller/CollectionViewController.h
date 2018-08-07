//
//  CollectionViewController.h
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *dataArr;//数据源

@property (nonatomic, strong) NSMutableArray *selectedArr;//选中待编辑的数据

@property (nonatomic, assign) NSInteger selectedNum;//选择的数据个数

@property (nonatomic, assign) BOOL isEditing;//是否处于编辑状态

@property (nonatomic, assign) BOOL isCell;//0:列表视图,1:网格视图

@property (nonatomic, strong) UIDocumentInteractionController *documentVC;//文件预览视图

@property (nonatomic, strong) NSString *filePath;//文件资源路径

- (void)initFilePath: (NSString*)path;//初始化数据的资源路径

/**
 *    @brief     排序
 *    @param     selectedSortType 选择的排序方式(1:名称 2:大小 3:日期 4:类型)
 *    @param     isDesc 是否降序
 *    @param     isDirectoryFirst 是否目录优先
 */
- (void)sortByTypes:(NSInteger)selectedSortType isDesc:(BOOL)isDesc isDirectoryFirst:(BOOL)isDirectoryFirst;

@end
