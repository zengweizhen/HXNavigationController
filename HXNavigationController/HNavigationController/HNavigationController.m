//
//  CCNavigationController.m
//  CCSlideNavigationTransition
//
//  Created by Jney on 2017/3/29.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import "HNavigationController.h"
//#import "HAppManager.h"
//#import "HXTabBarConfig.h"
#import "UIView+HXAddition.h"
#import "NSObject+HXAssociative.h"
#import "HXSlideAnimatedTransitioning.h"


static const NSTimeInterval kCCNavigationControllerSlidingAnimationDuration = 0.3;
static const CGFloat kCCNavigationControllerPanVelocityPositiveThreshold = 300;
static const CGFloat kCCNavigationControllerPanVelocityNegativeThreshold = - 300;
static const CGFloat kCCNavigationControllerPanProgressThreshold = 0.3;

static NSURL * _snapshotCacheURL = nil;
static BOOL _cacheSnapshotImageInMemory = YES;

@interface HNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *previousSnapshotView;
@property (nonatomic, assign) CGPoint gestureBeganPoint;
@property (nonatomic, assign) float transitioningProgress;
@property (nonatomic, strong) UIView *gestureView;


@property (nonatomic, strong) UIImage *tabBarView;

@end

@implementation HNavigationController

- (void)dealloc
{
    [self.backgroundView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)initialize
{
    @autoreleasepool {
        [[self class]removeCacheDirectory];//Application Launching Need To Clean All Disk Cache
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[self class]setCacheSnapshotImageInMemory:NO];
        
        [[self class] createCacheDirectory];
        
        _previousSlideViewInitailOriginX = - 200;
        _slidingPopEnable = YES;
        _useSystemAnimatedTransitioning = NO;
        _edgePopGestureOnly = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.supportLandscape = NO;
    self.gestureBack = YES;
    self.view.layer.shadowColor = [[UIColor blackColor]CGColor];
    self.view.layer.shadowOffset = CGSizeMake(6, 6);
    self.view.layer.shadowRadius = 5;
    self.view.layer.shadowOpacity = 0.9;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    UIGestureRecognizer *gesture = self.interactivePopGestureRecognizer;
    gesture.enabled = NO;
    self.gestureView = gesture.view;
    if (self.isSlidingPopEnable) {
        if ([self isAboveIOS7]) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
        [self addPanGestureRecognizers];
    }
    
    if (self.isUseSystemAnimatedTransitioning) {
        self.delegate = self;
    }
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromViewController
                                                 toViewController:(UIViewController*)toViewController
{
    if (UINavigationControllerOperationPush == operation) {
        HXSlideAnimatedTransitioning *transitoning = [[HXSlideAnimatedTransitioning alloc]initWithReverse:NO];
        transitoning.transitioningInitailOriginX = self.previousSlideViewInitailOriginX;
        return transitoning;
    }
    return nil;
}

#pragma mark - Helper

- (BOOL)isAboveIOS7
{
    return [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending;
}

- (NSString *)encodedFilePathForKey:(NSString *)key
{
    if (![key length]){
        return nil;
    }
    
    return [[[[self class]snapshotCacheURL] URLByAppendingPathComponent:[NSString stringWithUTF8String:[key UTF8String]]] path];
}

#pragma mark - Public

+ (BOOL)cacheSnapshotImageInMemory
{
    return _cacheSnapshotImageInMemory;
}

+ (void)setCacheSnapshotImageInMemory:(BOOL)cacheSnapshotImageInMemory
{
    _cacheSnapshotImageInMemory = cacheSnapshotImageInMemory;
}

#pragma mark - Private

+ (NSURL *)snapshotCacheURL
{
    if (!_snapshotCacheURL) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _snapshotCacheURL = [NSURL fileURLWithPathComponents:@[[paths objectAtIndex:0], @"SnapshotCache"]];
    }
    
    return _snapshotCacheURL;
}

+ (BOOL)createCacheDirectory
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[[self class]snapshotCacheURL] path]]) {
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:[[self class]snapshotCacheURL]
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    return success;
}

+ (BOOL)removeCacheDirectory
{
    NSError *error = nil;
    return [[NSFileManager defaultManager] removeItemAtURL:[[self class]snapshotCacheURL] error:&error];
}


- (void)setTransitioningProgress:(float)transitioningProgress
{
    _transitioningProgress = MIN(1,MAX(0, transitioningProgress));
}

- (void)layoutViewsWithTransitioningProgress:(float)progress
{
    self.transitioningProgress = progress;
    
    CGRect frame = self.view.frame;
    frame.origin.x = CGRectGetWidth([[UIScreen mainScreen] bounds]) * self.transitioningProgress;
    self.view.frame = frame;
    
    CGRect previewFrame = self.previousSnapshotView.frame;
    CGFloat offset = frame.origin.x * self.previousSlideViewInitailOriginX / previewFrame.size.width;
    previewFrame.origin.x = self.previousSlideViewInitailOriginX - offset;
    self.previousSnapshotView.frame = previewFrame;
}

- (void)excutePopAnimationWithDuration:(NSTimeInterval)duration completion:(void (^)(BOOL finish))completion
{
    [UIView animateWithDuration:duration animations:^{
        [self layoutViewsWithTransitioningProgress:1];
    } completion:^(BOOL finished) {
        self.backgroundView.hidden = YES;
        [self layoutViewsWithTransitioningProgress:0];
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)createPreviousSnapshotView
{
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    }
    if (!self.backgroundView.window) {
        [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
    }
    self.backgroundView.hidden = NO;
    [self.previousSnapshotView removeFromSuperview];
    self.previousSnapshotView = [[UIImageView alloc]initWithImage:[self snapshotForViewController:self.topViewController]];
    
    CGRect frame = self.backgroundView.bounds;
    frame.origin.x = self.previousSlideViewInitailOriginX;
    self.previousSnapshotView.frame = frame;
    
    [self.backgroundView addSubview:self.previousSnapshotView];
}

#pragma mark - Overwrite


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    ///获取present出下一个页面的controller
    ///如果存在presentViewController 则获取presentViewController出去的前一个viewController----presentingVC  如果presentingVC存在   则不截取tabBar
    UIViewController *presentingVC = self.viewControllers.firstObject.presentingViewController;
#warning 重写滑动返回动画
    //对当前的tabBar  进行截图
    UIView *view = nil;
    /*
    //如果tabBar存在并且nav里面只有一个viewController(tabBar初始化controller)则截取tabBar
    NSInteger count = self.viewControllers.count;
    if ((cyl_TabBarControllerConfig && (count == 1) && (presentingVC == nil)) || [presentingVC isKindOfClass:[self class]]) {
        //截取tabBar视图view
        view = [HXTabBarConfig manager].tabBarController.view;
        self.tabBarView = [view snapshotImage];
    }else{
        UIViewController *controller = self.viewControllers.lastObject;
        if (controller.view != nil) {
            view = self.view;
        }
    }
    */
    UIViewController *controller = self.viewControllers.lastObject;
    if (controller.view != nil) {
        view = self.view;
    }
    [self saveSnapshotImage:[view snapshotImage] forViewController:viewController];
    if (animated && !self.isUseSystemAnimatedTransitioning) {
        [self createPreviousSnapshotView];
        self.previousSnapshotView.image = [self snapshotForViewController:viewController];
        
        [super pushViewController:viewController animated:NO];
        
        [self layoutViewsWithTransitioningProgress:1];
        [UIView animateWithDuration:kCCNavigationControllerSlidingAnimationDuration animations:^{
            [self layoutViewsWithTransitioningProgress:0];
        }];
    } else {
        [super pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *popedViewController = nil;
    if (animated && !self.isUseSystemAnimatedTransitioning && self.viewControllers.count > 1) {
        [self createPreviousSnapshotView];
        
        [self removeSnapshotForViewController:self.topViewController];
        popedViewController = self.topViewController;
        
        [self layoutViewsWithTransitioningProgress:0];
        [self excutePopAnimationWithDuration:kCCNavigationControllerSlidingAnimationDuration completion:^(BOOL finish) {
            [super popViewControllerAnimated:NO];
        }];
    } else {
        [self removeSnapshotForViewController:self.topViewController];
        popedViewController = [super popViewControllerAnimated:animated];
    }
    
    return popedViewController;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray *popedControllers = nil;
    if (animated && !self.isUseSystemAnimatedTransitioning && self.viewControllers.count > 1) {
        [self createPreviousSnapshotView];
        self.previousSnapshotView.image = [self snapshotForViewController:self.viewControllers[1]];
        
        [self layoutViewsWithTransitioningProgress:0];
        
        NSMutableArray *mutablePopedControllers = [self.viewControllers mutableCopy];
        [mutablePopedControllers removeObjectAtIndex:0];
        popedControllers = mutablePopedControllers;
        
        [self excutePopAnimationWithDuration:kCCNavigationControllerSlidingAnimationDuration completion:^(BOOL finish) {
            [super popToRootViewControllerAnimated:NO];
        }];
    } else {
        popedControllers = [super popToRootViewControllerAnimated:animated];
    }
    
    for (UIViewController *controller in popedControllers) {
        [self removeSnapshotForViewController:controller];
    }
    return popedControllers;
}

#pragma mark - Snapshot

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated{
    
    NSInteger count = viewControllers.count;
    UIViewController *controller = viewControllers[count - 2];
    UIViewController *lastController = viewControllers[count - 1];
    controller.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [super setViewControllers:viewControllers animated:animated];
    if (count == 2) {
        [self saveSnapshotImage:self.tabBarView forViewController:lastController];
    }else{
        [self saveSnapshotImage:[controller.view snapshotImage] forViewController:lastController];
    }
}


- (void)saveSnapshotImage:(UIImage *)snapshotImage forViewController:(UIViewController *)controller
{
    [controller setAssociativeObject:snapshotImage forKey:[self cacheSnapshotImageKeyForViewController:controller]];
    
    if (![[self class] cacheSnapshotImageInMemory]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString *path = [self encodedFilePathForKey:[self cacheSnapshotImageKeyForViewController:controller]];
            BOOL isArchiveSuccess = [NSKeyedArchiver archiveRootObject:snapshotImage toFile:path];
            if (isArchiveSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [controller setAssociativeObject:nil forKey:[self cacheSnapshotImageKeyForViewController:controller]];
                });
            }
        });
    }
}

- (UIImage *)snapshotForViewController:(UIViewController *)controller
{
    UIImage *image = [controller associativeObjectForKey:[self cacheSnapshotImageKeyForViewController:controller]];
    if (!image) {
        NSString *path = [self encodedFilePathForKey:[self cacheSnapshotImageKeyForViewController:controller]];
        image = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    return image;
}

- (void)removeSnapshotForViewController:(UIViewController *)controller
{
    [controller setAssociativeObject:nil forKey:[self cacheSnapshotImageKeyForViewController:controller]];
    NSString *path = [self encodedFilePathForKey:[self cacheSnapshotImageKeyForViewController:controller]];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    [fileManager removeItemAtPath:path error:nil];
}

- (NSString *)cacheSnapshotImageKeyForViewController:(UIViewController *)controller
{
    return [NSString stringWithFormat:@"%lu_SnapshotImageKey.png", (unsigned long)controller.hash];
}

#pragma mark - Event

- (void)addPanGestureRecognizers{
    UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] init];
    popRecognizer.delegate = self;
    popRecognizer.maximumNumberOfTouches = 1;
    [self.gestureView addGestureRecognizer:popRecognizer];
    [popRecognizer addTarget:self action:@selector(handlePanGestureRecognizer:)];
}


- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    self.isBack = YES;
    __block UIView *view = pan.view;
    [view endEditing:YES];
    if (self.viewControllers.count < 2 || !self.isSlidingPopEnable || [pan numberOfTouches] > 1 || !self.gestureBack/* || ![HAppManager manager].canSwipeBack*/) {
        return;
    }
    
    CGPoint point = [pan locationInView:[UIApplication sharedApplication].keyWindow];
    self.transitioningProgress = (point.x - self.gestureBeganPoint.x) / [UIScreen mainScreen].bounds.size.width;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.gestureBeganPoint = point;
            [self createPreviousSnapshotView];
        } break;
            
        case UIGestureRecognizerStateChanged:
        {
            [self layoutViewsWithTransitioningProgress:self.transitioningProgress];
        }break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGPoint velocity = [pan velocityInView:pan.view];
            BOOL isFastPositiveSwipe = velocity.x > kCCNavigationControllerPanVelocityPositiveThreshold;
            BOOL isFastNegativeSwipe = velocity.x < kCCNavigationControllerPanVelocityNegativeThreshold;
            NSTimeInterval duration = (isFastNegativeSwipe || isFastPositiveSwipe) ? kCCNavigationControllerSlidingAnimationDuration
            : kCCNavigationControllerSlidingAnimationDuration;
            
            if ((self.transitioningProgress > kCCNavigationControllerPanProgressThreshold && !isFastNegativeSwipe) || isFastPositiveSwipe) {
                [self excutePopAnimationWithDuration:duration completion:^(BOOL finish) {
                    [self popViewControllerAnimated:NO];
                    ///结束滑动并且返回
                    self.isBack = NO;
                }];
            } else {
                [UIView animateWithDuration:duration animations:^{
                    [self layoutViewsWithTransitioningProgress:0];
                    
                    ///TODO  适用纯线 认证页面
                    ///结束滑动并且没有返回
                    self.isBack = NO;
                    //[[NSNotificationCenter defaultCenter] postNotificationName:HNav_Notification object:nil];
                }];
            }
        }break;
            
        default:
            break;
    }
}



@end
