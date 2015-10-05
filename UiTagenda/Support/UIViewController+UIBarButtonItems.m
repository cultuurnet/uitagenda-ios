//
//  UIViewController+UIBarButtonItems.m
//  UiTagenda
//
//  Created by Robbe Vandecasteele on 28/09/15.
//  Copyright © 2015 Cultuurnet. All rights reserved.
//

#import "UIViewController+UIBarButtonItems.h"
#import "UiTFavoritesViewController.h"
#import "UiTNavViewController.h"
#import "UiTSearchFilterViewController.h"

#import <NVSlideMenuController/NVSlideMenuController.h>

@implementation UIViewController (UIBarButtonItems)

- (UIBarButtonItem *)showBarButtonWithType:(UIBarButtonItemType)barButtonItemType {
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [barButton setFrame:CGRectMake(0, 0, 30, 30)];
    
    switch (barButtonItemType) {
        case UIBarButtonItemTypeList:
            [barButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
            [barButton addTarget:self action:@selector(openMenuView:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case UIBarButtonItemTypeClose:
            [barButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
            [barButton addTarget:self action:@selector(closeModalView) forControlEvents:UIControlEventTouchUpInside];
            break;
        case UIBarButtonItemTypeFavorite:
            [barButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
            [barButton addTarget:self action:@selector(showFavoritesModalAction) forControlEvents:UIControlEventTouchUpInside];
            break;
        case UIBarButtonItemTypeSearch:
            [barButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
            [barButton addTarget:self action:@selector(openSearchModal) forControlEvents:UIControlEventTouchUpInside];
            break;
        default:
            break;
    }
    
    return [[UIBarButtonItem alloc] initWithCustomView:barButton];
}

- (void)openMenuView:(id)sender {
    if (self.slideMenuController.isMenuOpen) {
        [self.slideMenuController closeMenuAnimated:YES completion:nil];
    } else {
        [self.slideMenuController openMenuAnimated:YES completion:nil];
    }
}

- (void)closeModalView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeFavorites" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openSearchModal {
    UiTNavViewController *navController = [[UiTNavViewController alloc] initWithNibName:nil bundle:nil];
    
    UiTSearchFilterViewController *searchFilterViewController = [[UiTSearchFilterViewController alloc] initWithNibName:nil bundle:nil];
    [navController setViewControllers:[[NSArray alloc] initWithObjects:
                                       searchFilterViewController,
                                       nil]];
    [self.slideMenuController closeMenuBehindContentViewController:navController animated:YES completion:nil];
    
    //    UiTSearchFilterViewController *searchFilterViewController = [[UiTSearchFilterViewController alloc] initWithNibName:nil bundle:nil];
    //    UiTNavViewController *navViewController = [[UiTNavViewController alloc] initWithRootViewController:searchFilterViewController];
    //    [self presentViewController:navViewController animated:YES completion:nil];
}

@end