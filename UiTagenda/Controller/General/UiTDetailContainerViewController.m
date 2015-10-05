//
//  UiTDetailContainerViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 21/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "UiTDetailContainerViewController.h"
#import "UiTDetailViewController.h"
#import "UiTFavoritesViewController.h"
#import "UiTNavViewController.h"

@interface UiTDetailContainerViewController ()

@property (nonatomic, strong) UIViewController *rootViewController;

@end

@implementation UiTDetailContainerViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super init];
    if (self) {
        self.rootViewController = rootViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"DETAIL", @"");
    [self.navigationItem setRightBarButtonItem:[self showRightBarButton:@"favorite"]];
    
	if ([self.childViewControllers count] == 0) {
        [self.rootViewController willMoveToParentViewController:self];
        [self addChildViewController:self.rootViewController];
        UIView *rootView = self.rootViewController.view;
        rootView.frame = self.view.bounds;
        [self.view addSubview:rootView];
        [self.rootViewController didMoveToParentViewController:self];
    }
}

- (void)switchViewController:(UiTEvent *)event andResultsArr:(NSArray *)eventsArray {
    UiTDetailViewController *viewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"homeDetailVC"];
    viewController.event = event;
    viewController.eventsArray = eventsArray;
//    UiTDetailViewController *viewController = [[UiTDetailViewController alloc] initWithEvent:event andEventsArray:eventsArray];
    
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    
    [self.view addSubview:viewController.view];
    
    [self.rootViewController willMoveToParentViewController:nil];
    
    [self transitionFromViewController:self.rootViewController
                      toViewController:viewController
                              duration:0
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                
                            } completion:^(BOOL finished){
                                [self.rootViewController.view removeFromSuperview];
                                [self.rootViewController removeFromParentViewController];
                                self.rootViewController = viewController;
                            }];
}

- (UIBarButtonItem *)showRightBarButton:(NSString *)imageName {
    UIImage *barBtnImage = [UIImage imageNamed:imageName];
    UIImage *barBtnImageActive = [UIImage imageNamed:[NSString stringWithFormat:@"%@Highlighted", imageName]];
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [barButton setBackgroundImage:barBtnImage forState:UIControlStateNormal];
    [barButton setBackgroundImage:barBtnImageActive forState:UIControlStateHighlighted];
    
    [barButton setFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
    
    [barButton addTarget:self action:@selector(showFavoritesModalAction) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:barButton];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    return item;
}

@end

@implementation UIViewController (DetailContainer)

- (UiTDetailContainerViewController *)detailContainer {
    return (UiTDetailContainerViewController *)self.parentViewController;
}

@end