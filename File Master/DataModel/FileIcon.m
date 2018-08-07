//
//  FileIcon.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "FileIcon.h"

#define MP3 "ico_small_mp3"
#define MP4 "ico_small_mov"
#define PIC "ico_small_bmp"
#define ZIP "ico_small_zip"
#define DOC "ico_small_doc"
#define PPT "ico_small_ppt"
#define XLS "ico_small_xls"
#define SWF "ico_small_swf"
#define XML "ico_small_xml"
#define KEY "ico_small_key"
#define PAGES "ico_small_pages"
#define NUMBERS "ico_small_numbers"
#define TXT "ico_small_txt"
#define PSD "ico_small_psd"
#define PDF "ico_small_pdf"
#define UNKOWN "ico_small_bat"

@implementation FileIcon

BOOL isFileInExtensionList(NSString* extension, NSArray* extensionlist) {
    if (extension == nil || extensionlist.count == 0) return NO;
    return [extensionlist containsObject:extension];
}

BOOL isMusicFile(NSString* fileName) {
    return isFileInExtensionList(fileName, @[@"mp3", @"aac", @"amr", @"ape", @"m4a", @"m4p", @"wav", @"wma", @"aiff",@"flac",@"cda",@"flac",@"mid",@"mka",@"mp2",@"mpa",@"mpc",@"ofr",@"ogg",@"ra",@"wv",@"tta",@"ac3",@"dts"]);
}

BOOL isVedioFile(NSString* fileName) {
    return isFileInExtensionList(fileName, @[@"avi", @"mp4", @"flv", @"mov", @"rm", @"rmvb", @"m4p", @"m4v", @"mpg", @"mpeg",@"mpe",@"mpv",@"3gp",@"asf",@"wmv",@"avs",@"flv",@"mkv",@"mov",@"3gp",@"dat",@"ogm",@"vob",@"rm",@"rmvb",@"ts",@"tp",@"ifo",@"nsv"]);
}

BOOL isPictureFile(NSString* fileName) {
    return isFileInExtensionList(fileName, @[@"jpg", @"png", @"bmp", @"jpeg", @"gif", @"tiff", @"tif",@"eps",@"mif",@"miff",@"tif",@"tiff",@"svg",@"wmf",@"jpe",@"dib",@"ico",@"icon"]);
}

BOOL isCompressFile(NSString *filename) {
    return isFileInExtensionList(filename, @[@"zip", @"rar", @"tar", @"gz", @"bz2"]);
}

BOOL isWordFile(NSString *filename){
    return isFileInExtensionList(filename, [NSArray arrayWithObjects:@"doc",@"docx",@"dot",@"wpt", nil]);
}

BOOL isPPTFile(NSString *filename){
    return isFileInExtensionList(filename, [NSArray arrayWithObjects:@"ppt",@"pptx",@"pot", nil]);
}

BOOL isExcelFile(NSString *filename){
    return isFileInExtensionList(filename, [NSArray arrayWithObjects:@"xls",@"xlsx",@"xlt",nil]);
}

BOOL isMailFile(NSString *filename){
    return isFileInExtensionList(filename, [NSArray arrayWithObjects:@"eml",nil]);
}

BOOL isFlashFile(NSString *filename){
    return isFileInExtensionList(filename, [NSArray arrayWithObjects:@"swf",nil]);
}

BOOL isBrowserFile(NSString *filename){
    return isFileInExtensionList(filename, [NSArray arrayWithObjects:@"html",@"htm",@"dhtml",@"mht",nil]);
}

BOOL isKeynoteFile(NSString *filename){
    return isFileInExtensionList(filename, [NSArray arrayWithObjects:@"key",nil]);
}

BOOL isPageFile(NSString *filename){
    return isFileInExtensionList(filename, [NSArray arrayWithObjects:@"pages",nil]);
}

BOOL isNumbersFile(NSString *filename){
    return isFileInExtensionList(filename, [NSArray arrayWithObjects:@"numbers",nil]);
}

BOOL isTextFile(NSString *filename){
    return isFileInExtensionList(filename,@[@"txt",@"log"]);
}

NSString *getFileIcon(NSString *fileName){
    if (fileName == nil) return nil;
    NSString *extension = [fileName pathExtension];
    extension = [extension lowercaseString];
    if (isMusicFile(extension)) {
        return @MP3;
    } else if (isVedioFile(extension)) {
        return @MP4;
    } else if (isPictureFile(extension)) {
        return @PIC;
    } else if (isCompressFile(extension)) {
        return @ZIP;
    } else if (isWordFile(extension)) {
        return @DOC;
    } else if (isPPTFile(extension)) {
        return @PPT;
    } else if (isExcelFile(extension)) {
        return @XLS;
    } else if (isMailFile(extension)) {
        return @UNKOWN;
    } else if (isFlashFile(extension)) {
        return @SWF;
    } else if (isBrowserFile(extension)) {
        return @XML;
    } else if (isKeynoteFile(extension)) {
        return @KEY;
    } else if (isPageFile(extension)) {
        return @PAGES;
    } else if (isNumbersFile(extension)) {
        return @NUMBERS;
    } else if (isTextFile(extension)) {
        return @TXT;
    } else if ([extension isEqualToString:@"psd"]) {
        return @PSD;
    } else if ([extension isEqualToString:@"pdf"]) {
        return @PDF;
    } else {
        return @UNKOWN;
    }
}

@end
