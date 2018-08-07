//
//  LeftSlipManager.h
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYLeftSlipManager : UIPercentDrivenInteractiveTransition

/**
 *	@brief	单例方法
 *  @return instancetype  DYLeftSlipManager左滑管理器实例
 */
+ (instancetype)sharedManager;

/**
 *	@brief	设置左滑视图及主视图
 *	@param 	leftViewController  左侧菜单视图控制器
 *	@param 	coverViewController  主控制器
 */
- (void)setLeftViewController:(UIViewController *)leftViewController coverViewController:(UIViewController *)coverViewController;

/**
 *	@brief	显示左滑视图
 */
- (void)showLeftView;

/**
 *	@brief	取消显示侧滑视图
 */
- (void)dismissLeftView;

/**
 *  @brief  点击菜单图标,打开或关闭视图
 */
- (void)menuClick;

@end
