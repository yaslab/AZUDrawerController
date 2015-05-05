//
//  AZUDrawerController.m
//  AZUDrawerController
//
//  Created by Yasuhiro Hatta on 2015/05/05.
//  Copyright (c) 2015年 yaslab. All rights reserved.
//

#import "AZUDrawerController.h"

@interface AZUDrawerController () <UIGestureRecognizerDelegate>

@property (nonatomic) UIView *shadowView;

@property (nonatomic) UIScreenEdgePanGestureRecognizer *leftEdgePanGestureRecognizer;
@property (nonatomic) BOOL leftViewControllerPresenting;

@property (nonatomic) UIScreenEdgePanGestureRecognizer *rightEdgePanGestureRecognizer;
@property (nonatomic) BOOL rightViewControllerPresenting;

@end

@implementation AZUDrawerController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGSize viewSize = self.view.frame.size;

    {
        CGRect frame = CGRectMake(0.f, 0.f, viewSize.width, viewSize.height);
        if (self.centerViewController.preferredContentSize.width < viewSize.width) {
            frame.size.width = self.centerViewController.preferredContentSize.width;
        }
        if (self.centerViewController.preferredContentSize.height < viewSize.height) {
            frame.size.height = self.centerViewController.preferredContentSize.height;
        }
        self.centerViewController.view.frame = frame;

        [self.centerViewController willMoveToParentViewController:self];
        [self.view addSubview:self.centerViewController.view];
        [self addChildViewController:self.centerViewController];
        [self.centerViewController didMoveToParentViewController:self];
    }

    {
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, viewSize.width, viewSize.height)];
        self.shadowView.backgroundColor = [UIColor blackColor];
        self.shadowView.alpha = 0.f;
        [self.view addSubview:self.shadowView];
    }

    if (self.leftViewController) {
        CGRect frame = CGRectMake(-1.f * viewSize.width, 0.f, viewSize.width, viewSize.height);
        if (self.leftViewController.preferredContentSize.width < viewSize.width) {
            frame.size.width = self.leftViewController.preferredContentSize.width;
            frame.origin.x = -1.f * frame.size.width;
        }
        if (self.leftViewController.preferredContentSize.height < viewSize.height) {
            frame.size.height = self.leftViewController.preferredContentSize.height;
        }
        self.leftViewController.view.frame = frame;

        [self.leftViewController willMoveToParentViewController:self];
        [self.view addSubview:self.leftViewController.view];
        [self addChildViewController:self.leftViewController];
        [self.leftViewController didMoveToParentViewController:self];

        self.leftViewControllerPresenting = NO;
    }

    if (self.rightViewController) {
        CGRect frame = CGRectMake(viewSize.width, 0.f, viewSize.width, viewSize.height);
        if (self.rightViewController.preferredContentSize.width < viewSize.width) {
            frame.size.width = self.rightViewController.preferredContentSize.width;
        }
        if (self.rightViewController.preferredContentSize.height < viewSize.height) {
            frame.size.height = self.rightViewController.preferredContentSize.height;
        }
        self.rightViewController.view.frame = frame;

        [self.rightViewController willMoveToParentViewController:self];
        [self.view addSubview:self.rightViewController.view];
        [self addChildViewController:self.rightViewController];
        [self.rightViewController didMoveToParentViewController:self];

        self.rightViewControllerPresenting = NO;
    }

    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        gesture.delegate = self;
        [self.view addGestureRecognizer:gesture];
    }

    {
        self.leftEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(onScreenEdgePan:)];
        self.leftEdgePanGestureRecognizer.edges = UIRectEdgeLeft;
        self.leftEdgePanGestureRecognizer.delegate = self;
        self.leftEdgePanGestureRecognizer.delaysTouchesBegan = NO;
        [self.view addGestureRecognizer:self.leftEdgePanGestureRecognizer];
    }

    {
        self.rightEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(onScreenEdgePan:)];
        self.rightEdgePanGestureRecognizer.edges = UIRectEdgeRight;
        self.rightEdgePanGestureRecognizer.delegate = self;
        self.rightEdgePanGestureRecognizer.delaysTouchesBegan = NO;
        [self.view addGestureRecognizer:self.rightEdgePanGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTap:(UITapGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateEnded:
            if (self.leftViewControllerPresenting) {
                self.leftViewControllerPresenting = NO;
                CGRect frame = self.leftViewController.view.frame;
                frame.origin.x = -1.f * frame.size.width;
                __weak __typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.25f delay:0.f options:0 animations:^{
                    weakSelf.leftViewController.view.frame = frame;
                    weakSelf.shadowView.alpha = 0.f;
                } completion:nil];
            }
            if (self.rightViewControllerPresenting) {
                self.rightViewControllerPresenting = NO;
                CGRect frame = self.rightViewController.view.frame;
                frame.origin.x = CGRectGetWidth(self.view.frame);
                __weak __typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.25f delay:0.f options:0 animations:^{
                    weakSelf.rightViewController.view.frame = frame;
                    weakSelf.shadowView.alpha = 0.f;
                } completion:nil];
            }
            break;
        default:
            break;
    }
}

- (void)onScreenEdgePan:(UIScreenEdgePanGestureRecognizer *)sender {
    NSLog(@"PAN");
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            // 端からの移動量
            // 右方向は+、左方向は-
            CGPoint translation = [sender translationInView:self.view];
            NSLog(@"TRN: (%@) (%@)", @(translation.x), @(translation.y));
            // 加速度
            CGPoint velocity = [sender velocityInView:self.view];
            NSLog(@"VEL: (%@) (%@)", @(velocity.x), @(velocity.y));

            if ([sender isEqual:self.leftEdgePanGestureRecognizer]) {
                CGRect frame = self.leftViewController.view.frame;
                frame.origin.x = -1.f * frame.size.width + translation.x;
                if (frame.origin.x > 0.f) {
                    frame.origin.x = 0.f;
                }
                self.leftViewController.view.frame = frame;
                // 背景の透明度
                CGFloat alpha = 0.5f * (1.f - (fabs(CGRectGetMinX(frame)) / CGRectGetWidth(frame)));
                self.shadowView.alpha = alpha;
            }
            else if ([sender isEqual:self.rightEdgePanGestureRecognizer]) {
                CGFloat viewWidth = CGRectGetWidth(self.view.frame);
                CGRect frame = self.rightViewController.view.frame;
                frame.origin.x = viewWidth + translation.x;
                if (frame.origin.x < viewWidth - frame.size.width) {
                    frame.origin.x = viewWidth - frame.size.width;
                }
                self.rightViewController.view.frame = frame;
                // 背景の透明度
                CGFloat alpha = 0.5f * ((viewWidth - CGRectGetMinX(frame)) / CGRectGetWidth(frame));
                self.shadowView.alpha = alpha;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if ([sender isEqual:self.leftEdgePanGestureRecognizer]) {
                CGRect frame = self.leftViewController.view.frame;
                CGFloat alpha = 0.f;
                if (frame.origin.x >= -1.f * (frame.size.width / 2.f)) {
                    frame.origin.x = 0.f;
                    alpha = 0.5f;
                    self.leftViewControllerPresenting = YES;
                }
                else {
                    frame.origin.x = -1.f * frame.size.width;
                    self.leftViewControllerPresenting = NO;
                }
                __weak __typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.25f delay:0.f options:0 animations:^{
                    weakSelf.leftViewController.view.frame = frame;
                    weakSelf.shadowView.alpha = alpha;
                } completion:nil];
            }
            else if ([sender isEqual:self.rightEdgePanGestureRecognizer]) {
                CGFloat viewWidth = CGRectGetWidth(self.view.frame);
                CGRect frame = self.rightViewController.view.frame;
                CGFloat alpha = 0.f;
                if (frame.origin.x <= viewWidth - (frame.size.width / 2.f)) {
                    frame.origin.x = viewWidth - frame.size.width;
                    alpha = 0.5f;
                    self.rightViewControllerPresenting = YES;
                }
                else {
                    frame.origin.x = viewWidth;
                    self.rightViewControllerPresenting = NO;
                }
                __weak __typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.25f delay:0.f options:0 animations:^{
                    weakSelf.rightViewController.view.frame = frame;
                    weakSelf.shadowView.alpha = alpha;
                } completion:nil];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Property Accesser

//- (void)setCenterViewController:(UIViewController *)centerViewController {
//
//}
//
//- (void)setLeftViewController:(UIViewController *)leftViewController {
//
//}
//
//- (void)setRightViewController:(UIViewController *)rightViewController {
//
//}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.leftEdgePanGestureRecognizer] ||
        [gestureRecognizer isEqual:self.rightEdgePanGestureRecognizer]) {
        if (self.leftViewControllerPresenting || self.rightViewControllerPresenting) {
            return NO;
        }
    }
    return YES;
}

#pragma mark -

- (void)showLeftWithAnimated:(BOOL)animated {
    CGRect frame = self.leftViewController.view.frame;
    frame.origin.x = 0.f;
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
    }
    self.leftViewController.view.frame = frame;
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)dismissLeftWithAnimated:(BOOL)animated {
    CGRect frame = self.leftViewController.view.frame;
    frame.origin.x = frame.size.width;
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
    }
    self.leftViewController.view.frame = frame;
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)showRightWithAnimated:(BOOL)animated {
    CGRect frame = self.rightViewController.view.frame;
    frame.origin.x = CGRectGetWidth(self.view.frame) - frame.size.width;
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
    }
    self.leftViewController.view.frame = frame;
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)dismissRightWithAnimated:(BOOL)animated {
    CGRect frame = self.rightViewController.view.frame;
    frame.origin.x = CGRectGetWidth(self.view.frame);
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
    }
    self.leftViewController.view.frame = frame;
    if (animated) {
        [UIView commitAnimations];
    }
}

@end
