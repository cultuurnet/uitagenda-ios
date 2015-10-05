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

@implementation UIViewController (Actions)

- (void)showFavoritesModalAction {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Favorites" bundle:nil];
    UiTFavoritesViewController *vc = [storyboard instantiateInitialViewController];
//    vc = [[UiTFavoritesViewController alloc] initWithModal:YES];
    vc.modal = YES;
    UiTNavViewController *nav = [[UiTNavViewController alloc] initWithRootViewController:vc];
    
    if (TARGETED_DEVICE_IS_IPAD) {
//        NSMutableArray *viewControllerArray = [[NSMutableArray alloc] initWithArray:[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers]];
//        self.splitViewController.delegate = (UiTBaseViewController *)contentViewController;
//        [viewControllerArray removeAllObjects];
//        [viewControllerArray addObject:vc];
//        [[self.splitViewController.viewControllers objectAtIndex:1] setViewControllers:viewControllerArray animated:NO];
        [self.splitViewController presentViewController:nav animated:YES completion:nil];
    } else {
//        UiTNavViewController *navigationViewController = [[UiTNavViewController alloc] init];
//        navigationViewController.viewControllers = @[ contentViewController ];
//        [self.slideMenuController closeMenuBehindContentViewController:navigationViewController animated:YES bounce:NO completion:nil];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

@end