//
//  AZUDrawerController.m
//  AZUDrawerController
//
//  Created by Yasuhiro Hatta on 2015/05/05.
//  Copyright (c) 2015年 yaslab. All rights reserved.
//

#import "AZUDrawerController.h"

@interface AZUDrawerController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *leftEdgePanGestureRecognizer;
@property (nonatomic) CGFloat leftViewControllerShowRatio;
@property (nonatomic, readonly) BOOL leftViewControllerPresenting;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *rightEdgePanGestureRecognizer;
@property (nonatomic) CGFloat rightViewControllerShowRatio;
@property (nonatomic, readonly) BOOL rightViewControllerPresenting;

@end

@implementation AZUDrawerController

@dynamic leftViewControllerPresenting;
@dynamic rightViewControllerPresenting;

- (void)viewDidLoad {
    [super viewDidLoad];

    {
        [self.centerViewController willMoveToParentViewController:self];
        [self.view addSubview:self.centerViewController.view];
        [self addChildViewController:self.centerViewController];
        [self.centerViewController didMoveToParentViewController:self];
    }

    {
        self.shadowView = [[UIView alloc] initWithFrame:CGRectZero];
        self.shadowView.backgroundColor = [UIColor blackColor];
        self.shadowView.alpha = 0.f;
        [self.view addSubview:self.shadowView];
    }

    if (self.leftViewController) {
        [self.leftViewController willMoveToParentViewController:self];
        [self.view addSubview:self.leftViewController.view];
        [self addChildViewController:self.leftViewController];
        [self.leftViewController didMoveToParentViewController:self];
    }

    if (self.rightViewController) {
        [self.rightViewController willMoveToParentViewController:self];
        [self.view addSubview:self.rightViewController.view];
        [self addChildViewController:self.rightViewController];
        [self.rightViewController didMoveToParentViewController:self];
    }

    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onViewClicked:)];
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGSize viewSize = self.view.frame.size;

    if (self.centerViewController) {
        CGRect frame = CGRectMake(0.f, 0.f, viewSize.width, viewSize.height);
        if (self.centerViewController.preferredContentSize.width < viewSize.width) {
            frame.size.width = self.centerViewController.preferredContentSize.width;
        }
        if (self.centerViewController.preferredContentSize.height < viewSize.height) {
            frame.size.height = self.centerViewController.preferredContentSize.height;
        }
        self.centerViewController.view.frame = frame;
    }

    CGFloat alpha = 0.5f * MAX(self.leftViewControllerShowRatio, self.rightViewControllerShowRatio);
    self.shadowView.frame = CGRectMake(0.f, 0.f, viewSize.width, viewSize.height);
    self.shadowView.alpha = alpha;

    if (self.leftViewController) {
        CGRect frame = CGRectZero;
        frame.size = self.leftViewController.preferredContentSize;
        // CGFLOAT_MAXを指定された場合の対処
        if (frame.size.width > viewSize.width) {
            frame.size.width = viewSize.width;
        }
        if (frame.size.height > viewSize.height) {
            frame.size.height = viewSize.height;
        }
        frame.origin.x = -1.f * frame.size.width * (1.f - self.leftViewControllerShowRatio);
        self.leftViewController.view.frame = frame;
    }

    if (self.rightViewController) {
        CGRect frame = CGRectZero;
        frame.size = self.rightViewController.preferredContentSize;
        // CGFLOAT_MAXを指定された場合の対処
        if (frame.size.width > viewSize.width) {
            frame.size.width = viewSize.width;
        }
        if (frame.size.height > viewSize.height) {
            frame.size.height = viewSize.height;
        }
        frame.origin.x = viewSize.width - (frame.size.width * self.rightViewControllerShowRatio);
        self.rightViewController.view.frame = frame;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onViewClicked:(UITapGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateEnded: {
            CGPoint point = [sender locationInView:sender.view];
            if (self.leftViewControllerPresenting) {
                if (!CGRectContainsPoint(self.leftViewController.view.frame, point)) {
                    self.leftViewControllerShowRatio = 0.f;
                    [self.view setNeedsLayout];
                    __weak __typeof(self) weakSelf = self;
                    [UIView animateWithDuration:0.25f delay:0.f options:0 animations:^{
                        [weakSelf.view layoutIfNeeded];
                    } completion:nil];
                }
            }
            if (self.rightViewControllerPresenting) {
                if (!CGRectContainsPoint(self.rightViewController.view.frame, point)) {
                    self.rightViewControllerShowRatio = 0.f;
                    [self.view setNeedsLayout];
                    __weak __typeof(self) weakSelf = self;
                    [UIView animateWithDuration:0.25f delay:0.f options:0 animations:^{
                        [weakSelf.view layoutIfNeeded];
                    } completion:nil];
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)onScreenEdgePan:(UIScreenEdgePanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            // 端からの移動量
            // 右方向は+、左方向は-
            CGPoint translation = [sender translationInView:self.view];

            if ([sender isEqual:self.leftEdgePanGestureRecognizer]) {
                CGRect frame = self.leftViewController.view.frame;
                frame.origin.x = -1.f * frame.size.width + translation.x;
                if (frame.origin.x > 0.f) {
                    frame.origin.x = 0.f;
                }
                self.leftViewControllerShowRatio = 1.f - (fabs(CGRectGetMinX(frame)) / CGRectGetWidth(frame));
            }
            else if ([sender isEqual:self.rightEdgePanGestureRecognizer]) {
                CGFloat viewWidth = CGRectGetWidth(self.view.frame);
                CGRect frame = self.rightViewController.view.frame;
                frame.origin.x = viewWidth + translation.x;
                if (frame.origin.x < viewWidth - frame.size.width) {
                    frame.origin.x = viewWidth - frame.size.width;
                }
                self.rightViewControllerShowRatio = (viewWidth - CGRectGetMinX(frame)) / CGRectGetWidth(frame);
            }
            [self.view setNeedsLayout];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if ([sender isEqual:self.leftEdgePanGestureRecognizer]) {
                CGRect frame = self.leftViewController.view.frame;
                if (frame.origin.x >= -1.f * (frame.size.width / 2.f)) {
                    self.leftViewControllerShowRatio = 1.f;
                }
                else {
                    self.leftViewControllerShowRatio = 0.f;
                }
                [self.view setNeedsLayout];
                [UIView animateWithDuration:0.25f delay:0.f options:0 animations:^{
                    [self.view layoutIfNeeded];
                } completion:nil];
            }
            else if ([sender isEqual:self.rightEdgePanGestureRecognizer]) {
                CGFloat viewWidth = CGRectGetWidth(self.view.frame);
                CGRect frame = self.rightViewController.view.frame;
                if (frame.origin.x <= viewWidth - (frame.size.width / 2.f)) {
                    self.rightViewControllerShowRatio = 1.f;
                }
                else {
                    self.rightViewControllerShowRatio = 0.f;
                }
                [self.view setNeedsLayout];
                [UIView animateWithDuration:0.25f delay:0.f options:0 animations:^{
                    [self.view layoutIfNeeded];
                } completion:nil];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - 

- (BOOL)leftViewControllerPresenting {
    return self.leftViewControllerShowRatio > 0.f;
}

- (BOOL)rightViewControllerPresenting {
    return self.rightViewControllerShowRatio > 0.f;
}

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
