//
//  LeftSlipManager.m
//  File Master
//
//  Created by wyx on 2018/5/25.
//  Copyright © 2018年 wyx. All rights reserved.
//

#import "LeftSlipManager.h"
#import <objc/runtime.h>

@interface UINavigationController (DYLM_Push)

+ (void)swizzlingPushAndPop;

@end

static const void *DYLM_PushStateObserveKey = &DYLM_PushStateObserveKey;

@interface UIScreenEdgePanGestureRecognizer (DYLM_Push)

@property (nonatomic, weak) id stateObserve;

@end

@implementation UIScreenEdgePanGestureRecognizer (DYLM_Push)

- (void)setStateObserve:(id)stateObserve {
    objc_setAssociatedObject(self, DYLM_PushStateObserveKey, stateObserve, OBJC_ASSOCIATION_ASSIGN);
}

- (id)stateObserve {
    return objc_getAssociatedObject(self, DYLM_PushStateObserveKey);
}

@end

// 单例对象
static DYLeftSlipManager *_leftSlipManager = nil;
// 手势轻扫临界速度
CGFloat const DYLeftSlipCriticalVelocity = 1000;
// 左滑手势触发距离
CGFloat const DYLeftSlipLeftSlipPanTriggerWidth = 100;

@interface DYLeftSlipManager ()<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>
/** 是否已经显示左滑视图 */
@property (nonatomic, assign) BOOL showLeft;
/** 点击返回的遮罩view */
@property (nonatomic, strong) UIView *tapView;
/** 是否在交互中 */
@property (nonatomic, assign) BOOL interactive;
/** present or dismiss */
@property (nonatomic, assign) BOOL present;
/** 左滑视图宽度 */
@property (nonatomic, assign) CGFloat leftViewWidth;
@property (nonatomic, strong) UIViewController *leftVC;
@property (nonatomic, weak) UIViewController *coverVC;

/** 侧滑手势 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

/** 待处理的navigationController */

@end

@implementation DYLeftSlipManager

#pragma mark - 单例方法
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _leftSlipManager = [[self alloc] init];
        _leftSlipManager.leftViewWidth = [UIScreen mainScreen].bounds.size.width * 0.8;
    });
    return _leftSlipManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _leftSlipManager = [super allocWithZone:zone];
    });
    return _leftSlipManager;
}

- (id)copyWithZone:(NSZone *)zone {
    return _leftSlipManager;
}

#pragma mark - 初始化方法
- (instancetype)init {
    if (self = [super init]) {
        self.completionCurve = UIViewAnimationCurveLinear;
    }
    return self;
}

#pragma mark - public Methods
- (void)setLeftViewController:(UIViewController *)leftViewController coverViewController:(UIViewController *)coverViewController {
    self.leftVC = leftViewController;
    self.coverVC = coverViewController;
    [self.coverVC.view addSubview:self.tapView];
    // 转场代理
    self.leftVC.transitioningDelegate = self;
    // 侧滑手势
    [self.coverVC.view addGestureRecognizer:self.panGesture];
    [UINavigationController swizzlingPushAndPop];
}

- (void)showLeftView {
    [self.coverVC presentViewController:self.leftVC animated:YES completion:nil];
}

- (void)dismissLeftView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.leftVC dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)menuClick {
    if (!self.showLeft) {
        [self showLeftView];
    } else {
        [self dismissLeftView];
    }
}

#pragma mark - private Methods
/**
 *	@brief	设置滑动手势是否可用
 *	@param 	enabled 可用状态
 */
- (void)setGestureEnabled:(BOOL)enabled {
    self.panGesture.enabled = enabled;
}

/**
 *	@brief	是否需要拦截UINavigationController
 *	@param 	viewController  需要判断的VC
 *  @return BOOL  YES代表通过拦截，NO代表被拦截
 */
- (BOOL)shouldInterceptNaviVC:(UIViewController *)viewController {
    if ([viewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *naviVC = (UINavigationController *)viewController;
        return naviVC.viewControllers.count == 1;
    }
    return YES;
}

/**
 *	@brief	是否启用Pan手势
 *  @return BOOL  Pan手势是否可用
 *  @discussion 防止导航栏push了新视图后，更改右滑手势导致侧滑出菜单
 */
- (BOOL)shouldPanGestureEnabled {
    // 判断self.coverVC是否是UINavigationController
    BOOL naviAspectResult = [self shouldInterceptNaviVC:self.coverVC];
    if (!naviAspectResult) {
        return NO;
    }
    // 判断self.coverVC是否是UITabBarController，再判断当前的子控制器是否是UINavigationController
    if ([self.coverVC isKindOfClass:UITabBarController.class]) {
        UITabBarController *tabBarVC = (UITabBarController *)self.coverVC;
        UIViewController *selectVC = tabBarVC.selectedViewController;
        return [self shouldInterceptNaviVC:selectVC];
    }
    return YES;
}

#pragma mark - 手势处理方法
- (void)pan:(UIPanGestureRecognizer *)pan {
    if (![self shouldPanGestureEnabled]) {
        [self setGestureEnabled:NO];
        return;
    }
    // X轴偏移
    CGFloat offsetX = [pan translationInView:pan.view].x;
    // X轴速度
    CGFloat velocityX = [pan velocityInView:pan.view].x;
    
    CGFloat percent;
    if (self.showLeft) {
        // 坑点。千万不要超过1
        percent = MIN(-offsetX / self.leftViewWidth, 1);
    } else {
        percent = MIN(offsetX / self.leftViewWidth, 1);
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.interactive = YES;
            if (self.showLeft) {
                [self dismissLeftView];
            } else {
                [self showLeftView];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self updateInteractiveTransition:percent];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.interactive = NO;
            // 判断是否需要转场
            BOOL shouldTransition = NO;
            // 1.present时
            // 1.1 速度正方向，>800，则正向转场
            // 1.2 速度反向时，<-800，则反向转场
            // 1.3 速度正向<800 或者 速度反向>-800， 判断percent是否大于0.5
            if (!self.showLeft) {
                if (velocityX > 0) {
                    if (velocityX > DYLeftSlipCriticalVelocity) {
                        shouldTransition = YES;
                    } else {
                        shouldTransition = percent > 0.5;
                    }
                } else {
                    if (velocityX < -DYLeftSlipCriticalVelocity) {
                        shouldTransition = NO;
                    } else {
                        shouldTransition = percent > 0.5;
                    }
                }
            } else {
                if (velocityX < 0) {
                    if (velocityX < -DYLeftSlipCriticalVelocity) {
                        shouldTransition = YES;
                    } else {
                        shouldTransition = percent > 0.5;
                    }
                } else {
                    if (velocityX > DYLeftSlipCriticalVelocity) {
                        shouldTransition = NO;
                    } else {
                        shouldTransition = percent > 0.5;
                    }
                }
            }
            // 2.dismiss时
            // 2.1 速度正向，<-800，则正向转场
            // 2.2 速度反向，>800，则反向转场
            // 2.3 速度正向>-800 或者 速度反向<800，判断percent是否大于0.5
            if (shouldTransition) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate Methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.showLeft) {
        return YES;
    }
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
    // 忽略起始点不在左侧触发范围内的手势
    CGFloat touchBeganX = [panGesture locationInView:panGesture.view].x;
    if (touchBeganX > DYLeftSlipLeftSlipPanTriggerWidth) {
        return NO;
    }
    // 忽略反向手势
    CGPoint translation = [panGesture translationInView:panGesture.view];
    if (translation.x <= 0) {
        return NO;
    }
    return YES;
}

#pragma mark - UIViewControllerTransitioningDelegate代理方法
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.present = YES;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.present = NO;
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self : nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactive ? self : nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning代理方法
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.present) {
        // 基础操作，获取两个VC并把视图加在容器上
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIView *containerView = [transitionContext containerView];
        toVC.view.frame = CGRectMake(0, 0, self.leftViewWidth, containerView.frame.size.height);
        [containerView addSubview:toVC.view];
        [containerView sendSubviewToBack:toVC.view];
        // 将tapView提前，防止pop回来将tabbar提前
        [self.tapView.superview bringSubviewToFront:self.tapView];
        // 动画block
        void(^animateBlock)(void) = ^{
            fromVC.view.frame = CGRectMake(self.leftViewWidth, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height);
            self.tapView.alpha = 1.f;
        };
        // 动画完成block
        void(^completeBlock)(void) = ^{
            if ([transitionContext transitionWasCancelled]) {
                [transitionContext completeTransition:NO];
            } else {
                [transitionContext completeTransition:YES];
                [containerView addSubview:fromVC.view];
                // 加上点击dismiss的View
                // [fromVC.view addSubview:self.tapView];
                self.showLeft = YES;
            }
        };
        // 手势和普通动画做区别
        if (self.interactive) {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                animateBlock();
            } completion:^(BOOL finished) {
                completeBlock();
            }];
        } else {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                animateBlock();
            } completion:^(BOOL finished) {
                completeBlock();
            }];
        }
    } else {
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *containerView = [transitionContext containerView];
        [containerView addSubview:toVC.view];
        // 动画block
        void(^animateBlock)(void) = ^{
            toVC.view.frame = CGRectMake(0, 0, toVC.view.frame.size.width, toVC.view.frame.size.height);
            self.tapView.alpha = 0.f;
        };
        // 动画完成block
        void(^completeBlock)(void) = ^{
            if ([transitionContext transitionWasCancelled]) {
                [transitionContext completeTransition:NO];
            } else {
                [transitionContext completeTransition:YES];
                self.showLeft = NO;
                // 去除点击dismiss的View
                // [self.tapView removeFromSuperview];
            }
        };
        if (self.interactive) {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                animateBlock();
            } completion:^(BOOL finished) {
                completeBlock();
            }];
        } else {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                animateBlock();
            } completion:^(BOOL finished) {
                completeBlock();
            }];
        }
    }
}

#pragma mark - KVO Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:@"state"]) {
        return;
    }
    UIGestureRecognizerState state = [change[@"new"] integerValue];
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled || state == UIGestureRecognizerStateFailed) {
        UINavigationController *naviVC = (__bridge UINavigationController *)(context);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setGestureEnabled:naviVC.viewControllers.count == 1];
            if (naviVC.viewControllers.count == 1) {
                UIScreenEdgePanGestureRecognizer *gesture = (UIScreenEdgePanGestureRecognizer *)object;
                // 关闭导航栏侧滑手势
                gesture.enabled = NO;
                // 去除手势观察者
                if (gesture.stateObserve) {
                    [object removeObserver:self forKeyPath:keyPath];
                    [gesture setStateObserve:nil];
                }
            }
        });
    }
}

#pragma mark - setter/getter方法
- (UIView *)tapView {
    if (!_tapView) {
        _tapView = [[UIView alloc] initWithFrame:self.coverVC.view.bounds];
        _tapView.backgroundColor = [UIColor colorWithWhite:0 alpha:.2f];
        _tapView.alpha = 0.f;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissLeftView)];
        [_tapView addGestureRecognizer:tapGesture];
    }
    return _tapView;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

@end

/**
 动态交换方法
 @param class 需要交换的类
 @param sourceSelector 原始方法
 @param customSelector 交换方法
 */
static inline void swizzlingInstanceMethods(Class class, SEL sourceSelector, SEL customSelector) {
    Method sourceMethod = class_getInstanceMethod(class, sourceSelector);
    Method customMethod = class_getInstanceMethod(class, customSelector);
    if (class_addMethod(class, sourceSelector, method_getImplementation(customMethod), method_getTypeEncoding(customMethod))) {
        class_replaceMethod(class, customSelector, method_getImplementation(sourceMethod), method_getTypeEncoding(sourceMethod));
    } else {
        method_exchangeImplementations(sourceMethod, customMethod);
    }
}

@implementation UINavigationController (DYLM_Push)

+ (void)swizzlingPushAndPop {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzlingInstanceMethods(self, @selector(pushViewController:animated:), @selector(DYL_pushViewController:animated:));
        swizzlingInstanceMethods(self, @selector(popViewControllerAnimated:), @selector(DYL_popViewControllerAnimated:));
        swizzlingInstanceMethods(self, @selector(popToViewController:animated:), @selector(DYL_popToViewController:animated:));
        swizzlingInstanceMethods(self, @selector(popToRootViewControllerAnimated:), @selector(DYL_popToRootViewControllerAnimated:));
        swizzlingInstanceMethods(self, NSSelectorFromString(@"dealloc"), @selector(DYL_dealloc));
    });
}

- (BOOL)shouldRefreshDYLMGesture {
    return self.presentingViewController == nil;
}

- (void)refreshDYLMGestureEnabled {
    if ([self shouldRefreshDYLMGesture]) {
        [[DYLeftSlipManager sharedManager] setGestureEnabled:self.viewControllers.count == 1];
    }
}

- (void)DYL_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {\
    [self DYL_pushViewController:viewController animated:animated];
    // 判断是否需要刷新侧滑菜单的手势，在第一次被present出来的时候，self.presentingViewController为nil，此时必须依靠self.viewControllers.count进行判断是否是present出来
    if (![self shouldRefreshDYLMGesture] || self.viewControllers.count == 1) {
        return;
    }
    
    [self refreshDYLMGestureEnabled];
    
    // 该navigationController的全屏滑动手势
    UIScreenEdgePanGestureRecognizer *interactivePopGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)self.interactivePopGestureRecognizer;
    if (!interactivePopGestureRecognizer.stateObserve) {
        // 监听手势的状态
        [interactivePopGestureRecognizer addObserver:[DYLeftSlipManager sharedManager] forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(self)];
        [interactivePopGestureRecognizer setStateObserve:[DYLeftSlipManager sharedManager]];
    }
    
    if (self.viewControllers.count > 1) {
        // 开启导航栏手势交互
        interactivePopGestureRecognizer.enabled = YES;
    }
    /**********************************************************************************************/
//    // 手势执行的target
//    id gestureRecognizerTarget = ((NSArray *)[interactivePopGestureRecognizer valueForKey:@"_targets"]).firstObject;
//    // 执行handleNavigationTransition:的私有对象
//    id navigationInteractiveTransition = [gestureRecognizerTarget valueForKeyPath:@"_target"];
//    _target = navigationInteractiveTransition;
    /**********************************************************************************************/
}

- (UIViewController *)DYL_popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [self DYL_popViewControllerAnimated:animated];
    // 判断是否需要刷新侧滑菜单的手势
    if ([self shouldRefreshDYLMGesture]) {
        if (viewController) {
            [self refreshDYLMGestureEnabled];
        } else {
            UIScreenEdgePanGestureRecognizer *interactivePopGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)self.interactivePopGestureRecognizer;
            interactivePopGestureRecognizer.enabled = NO;
        }
    }
    return viewController;
}

- (NSArray<__kindof UIViewController *> *)DYL_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray<__kindof UIViewController *> *vcArray = [self DYL_popToViewController:viewController animated:animated];
    // 判断是否需要刷新侧滑菜单的手势
    if ([self shouldRefreshDYLMGesture]) {
        [self refreshDYLMGestureEnabled];
    }
    return vcArray;
}

- (NSArray<__kindof UIViewController *> *)DYL_popToRootViewControllerAnimated:(BOOL)animated {
    NSArray<__kindof UIViewController *> *vcArray = [self DYL_popToRootViewControllerAnimated:animated];
    // 判断是否需要刷新侧滑菜单的手势
    if ([self shouldRefreshDYLMGesture]) {
        [self refreshDYLMGestureEnabled];
    }
    return vcArray;
}

- (void)DYL_dealloc {
    // 该navigationController的全屏滑动手势
    UIScreenEdgePanGestureRecognizer *interactivePopGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)self.interactivePopGestureRecognizer;
    // 移除KVO监听
    if (interactivePopGestureRecognizer.stateObserve) {
        [interactivePopGestureRecognizer removeObserver:interactivePopGestureRecognizer.stateObserve forKeyPath:@"state"];
    }
    [self DYL_dealloc];
}

@end
