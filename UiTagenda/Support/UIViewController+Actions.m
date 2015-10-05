//
//  UIViewController+Actions.m
//  UiTagenda
//
//  Created by Robbe Vandecasteele on 02/10/15.
//  Copyright © 2015 Cultuurnet. All rights reserved.
//

#import "UIViewController+Actions.h"
#import "UiTNavViewController.h"
#import "UiTFavoritesViewController.h"
#import "UiTSearchFilterViewController.h"
#import "UiTBaseViewController.h"

#import "NVSlideMenuController/NVSlideMenuController.h"

@implementation UIViewController (Actions)

- (void)showFavoritesModalAction {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Favorites" bundle:nil];
    UiTFavoritesViewController *vc = [storyboard instantiateInitialViewController];
    vc.modal = YES;
    UiTNavViewController *nav = [[UiTNavViewController alloc] initWithRootViewController:vc];
    
    if (TARGETED_DEVICE_IS_IPAD) {
        [self.splitViewController presentViewController:nav animated:YES completion:nil];
    } else {
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)showSearchModalAction {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:[NSBundle mainBundle]];
    UIViewController *contentViewController = [storyboard instantiateInitialViewController];
    
    if (TARGETED_DEVICE_IS_IPAD) {
        NSMutableArray *viewControllerArray = [[NSMutableArray alloc] initWithArray:[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers]];
        self.splitViewController.delegate = (UiTBaseViewController *)contentViewController;
        [viewControllerArray removeAllObjects];
        [viewControllerArray addObject:contentViewController];
        [[self.splitViewController.viewControllers objectAtIndex:1] setViewControllers:viewControllerArray animated:NO];
    } else {
        UiTNavViewController *navigationViewController = [[UiTNavViewController alloc] init];
        navigationViewController.viewControllers = @[ contentViewController ];
        [self.slideMenuController closeMenuBehindContentViewController:navigationViewController animated:YES bounce:NO completion:nil];
    }
}

@end