//
//  LoginTableViewCell.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "LoginTableViewCell.h"

#define BLUECOLOR [UIColor colorWithDisplayP3Red:51/255.0 green:171/255.0 blue:238/255.0 alpha:1]

@interface LoginTableViewCell () <UITextFieldDelegate>

@end

@implementation LoginTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.loginInput.backgroundColor = [UIColor clearColor];
    self.loginInput.textColor = BLUECOLOR;
    //修改光标颜色
    [[UITextField appearance] setTintColor:BLUECOLOR];
    //输入框中是否有个叉号,在什么时候显示,用于一次性删除输入框中的内容(编辑时出现)
    self.loginInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.loginInput.layer.borderWidth = 0;
    self.loginInput.borderStyle = UITextBorderStyleNone;
    self.loginInput.delegate = self;
    self.backgroundColor = [UIColor clearColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
    [self.loginInput resignFirstResponder];
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
