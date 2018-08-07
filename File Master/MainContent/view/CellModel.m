//
//  CellModel.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "CellModel.h"

@implementation CellModel

- (void)setData:(NSString *)iconName name:(NSString *)name createTime:(NSString *)createTime size:(NSString *)size {
    self.iconName = iconName;
    self.name = name;
    self.createTime = createTime;
    self.size = size;
}

@end
