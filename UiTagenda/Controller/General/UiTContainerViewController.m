//
//  UiTContainerViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTContainerViewController.h"
#import "CustomSplitViewController.h"
#import "UiTHomeViewController.h"
#import "UiTNavViewController.h"
#import "UiTMenuViewController.h"

#import <NVSlideMenuController/NVSlideMenuController.h>
#import <TBMacros/Macros.h>

@interface UiTContainerViewController ()

@property (nonatomic, strong) UIViewController *rootViewController;

@end

@implementation UiTContainerViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super init];
    if (self) {
        self.rootViewController = rootViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	if ([self.childViewControllers count] == 0) {
        [self.rootViewController willMoveToParentViewController:self];
        [self addChildViewController:self.rootViewController];
        UIView *rootView = self.rootViewController.view;
        rootView.frame = self.view.bounds;
        [self.view addSubview:rootView];
        [self.rootViewController didMoveToParentViewController:self];
    }
}

- (void)switchViewController:(UIViewController *)viewController {
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    
    [self.view addSubview:viewController.view];
    
    [self.rootViewController willMoveToParentViewController:nil];
    
    [self transitionFromViewController:self.rootViewController
                      toViewController:viewController
                              duration:0.3f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
        
    } completion:^(BOOL finished) {
        [self.rootViewController.view removeFromSuperview];
        [self.rootViewController removeFromParentViewController];
        self.rootViewController = viewController;
    }];
}

- (UIViewController *)getContentViewControllers {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];

    if (TARGETED_DEVICE_IS_IPAD) {
        CustomSplitViewController *splitVC = [[CustomSplitViewController alloc] init];
        UiTHomeViewController *homeVC = [storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
        splitVC.delegate = homeVC;
        splitVC.viewControllers = @[ [[UiTNavViewController alloc] initWithRootViewController:[[UiTMenuViewController alloc] init]],
                                     [[UiTNavViewController alloc] initWithRootViewController:homeVC] ];
        return splitVC;
    } else {
        UiTNavViewController *nav = [storyboard instantiateViewControllerWithIdentifier:@"homeNav"];
//        UiTHomeViewController *homeVC = [storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
        NVSlideMenuController *slideMenuController = [[NVSlideMenuController alloc] initWithMenuViewController:[[UiTMenuViewController alloc] init]
                                                                                      andContentViewController:nav];
        return slideMenuController;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

@implementation UIViewController (ProjectContainer)

-(UiTContainerViewController *)projectContainer {
    return (UiTContainerViewController *)self.parentViewController;
}

@end