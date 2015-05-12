//
//  AZUDrawerController.h
//  AZUDrawerController
//
//  Created by Yasuhiro Hatta on 2015/05/05.
//  Copyright (c) 2015年 yaslab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZUDrawerController : UIViewController

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

- (void)showLeftWithAnimated:(BOOL)animated;
- (void)dismissLeftWithAnimated:(BOOL)animated;

- (void)showRightWithAnimated:(BOOL)animated;
- (void)dismissRightWithAnimated:(BOOL)animated;

@end
