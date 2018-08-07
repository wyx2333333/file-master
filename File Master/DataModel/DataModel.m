//
//  DataModel.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "DataModel.h"
#import "FileIcon.h"

#define FOLDER "ico_small_folder"

@implementation DataModel

-(instancetype)initWithPath:(NSString*)path {
    self = [super init];
    if (self) {
        self.dataSource = [[NSMutableArray alloc] init];
        //查找需要遍历文件夹的目录
        NSString *kDocumentsPath = path;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSDirectoryEnumerator *dirEnumerater = [fm enumeratorAtPath:kDocumentsPath];
        NSString *filePath = nil;
        //开始遍历文件
        while (nil != (filePath = [dirEnumerater nextObject])) {
            NSString *msgdir = [NSString stringWithFormat:@"%@/%@",kDocumentsPath,filePath];
            BOOL isDir;
            //比对文件类型，删除不相关类型的文件
            if ([fm fileExistsAtPath:msgdir isDirectory:&isDir]) {
                NSString *fileNameStr = [filePath lastPathComponent];
                NSString *filePath = msgdir;
                //文件修改时间
                NSDictionary *attributes = [fm attributesOfItemAtPath:msgdir error:nil];
                NSDate *theModifiDate;
                if ((theModifiDate = [attributes objectForKey:NSFileModificationDate])) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                    NSString *dateStr = [formatter stringFromDate:theModifiDate];
                    NSFileManager *manager = [NSFileManager defaultManager];
                    long long size = 0;
                    //文件优先级(文件夹为1,其他为0)
                    NSNumber *priority = [NSNumber numberWithInt:0];
                    if ([manager fileExistsAtPath:filePath]){
                        if (isDir) {
                            size = [self folderSizeAtPath:filePath];
                        } else {
                            size = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
                        }
                    }
                    //系统自带字节大小转换方法
                    //[NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
                    //获取不同文件类型的图标icon
                    NSString *iconName = getFileIcon(filePath);
                    //目录文件图标
                    if (isDir) {
                        iconName = @FOLDER;
                        //如果是文件夹跳出下一层遍历
                        [dirEnumerater skipDescendants];
                        priority = [NSNumber numberWithInt:1];
                    }
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:iconName, @"iconName", fileNameStr, @"name", filePath, @"path", dateStr, @"time", [self transformedValue:size], @"size", [NSNumber numberWithLongLong:size], @"noTransformedSize", priority, @"priority", nil];
                    [self.dataSource addObject:dic];
                }
            }
        }
    }
    return self;
}
    
//遍历文件夹获得文件夹大小，返回字节
- (long long)folderSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray * items = [manager contentsOfDirectoryAtPath:filePath error:nil];
    long long folderSize = 0;
    for (int i =0; i<items.count; i++) {
        BOOL subisdir;
        NSString* fileAbsolutePath = [filePath stringByAppendingPathComponent:items[i]];
        [manager fileExistsAtPath:fileAbsolutePath isDirectory:&subisdir];
        if (subisdir == YES) {
            folderSize += [self folderSizeAtPath:fileAbsolutePath];//文件夹就递归计算
        } else {
            folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];//文件直接计算
        }
    }
    return folderSize;
}

//文件大小字节单位转换
-(NSString*)transformedValue:(double)value {
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"B",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB",nil];
    while (value > 1000) {
        value /= 1000;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%.2f %@",value, [tokens objectAtIndex:multiplyFactor]];
}

@end

