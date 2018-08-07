//
//  CellModel.h
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellModel : NSObject

@property (nonatomic, strong) NSString *iconName;//文件图片icon名

@property (nonatomic, strong) NSString *name;//文件名

@property (nonatomic, strong) NSString *createTime;//文件创建时间

@property (nonatomic, strong) NSString *size;//文件大小

- (void)setData: (NSString *)iconName name: (NSString *)name createTime: (NSString *)createTime size: (NSString *)size;//给每一个cell设置具体数据

@end
