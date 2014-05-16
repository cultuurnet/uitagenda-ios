//
//  UiTBaseViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTBaseViewController.h"
#import "NVSlideMenuController/NVSlideMenuController.h"
#import "UiTNavViewController.h"
#import "UiTFavoritesViewController.h"
#import "UiTSearchModalViewController.h"
#import "UiTSearchFilterViewController.h"

@interface UiTBaseViewController ()

@end

@implementation UiTBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.navigationItem.leftBarButtonItem = [self showBarButton:@"list"];
    
    UIBarButtonItem *btnSearch = [self showBarButton:@"search"];
    UIBarButtonItem *btnFavorite = [self showBarButton:@"favorite"];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: btnFavorite, btnSearch, nil]];
}

- (UIBarButtonItem *)showBarButton:(NSString *)imageName {
    UIImage *barBtnImage = [UIImage imageNamed:imageName];
    UIImage *barBtnImageActive = [UIImage imageNamed:[NSString stringWithFormat:@"%@Highlighted", imageName]];
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [barButton setBackgroundImage:barBtnImage forState:UIControlStateNormal];
    [barButton setBackgroundImage:barBtnImageActive forState:UIControlStateHighlighted];
    
    [barButton setFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
    
    UIView *containerView;
    
    if ([imageName isEqualToString:@"list"]) {
        [barButton setFrame:CGRectMake(0, 0, barBtnImage.size.width + 5, barBtnImage.size.height + 5)];
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
        [barButton addTarget:self
                      action:@selector(openMenuView:)
            forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([imageName isEqualToString:@"favorite"]) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
        [barButton addTarget:self
                      action:@selector(openFavoritesModal)
            forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([imageName isEqualToString:@"search"]) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barBtnImage.size.width - 5, barBtnImage.size.height)];
        [barButton addTarget:self
                      action:@selector(openSearchModal)
            forControlEvents:UIControlEventTouchUpInside];
    }
    
    [containerView addSubview:barButton];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    return item;
}

- (UIBarButtonItem *)showRightBarButton:(NSString *)imageName {
    
    UIImage *barBtnImage = [UIImage imageNamed:imageName];
    UIImage *barBtnImageActive = [UIImage imageNamed:[NSString stringWithFormat:@"%@Highlighted", imageName]];
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [barButton setBackgroundImage:barBtnImage forState:UIControlStateNormal];
    [barButton setBackgroundImage:barBtnImageActive forState:UIControlStateHighlighted];
    
    [barButton setFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
    
    [barButton addTarget:self action:@selector(closeModalView) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:barButton];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    return item;
}

-(void)closeModalView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeFavorites" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openMenuView:(id)sender {
    if (self.slideMenuController.isMenuOpen) {
        [self.slideMenuController closeMenuAnimated:YES completion:nil];
    }
    else {
        [self.slideMenuController openMenuAnimated:YES completion:nil];
    }
}

-(void)openFavoritesModal {
    UiTFavoritesViewController *favoritesViewController = [[UiTFavoritesViewController alloc] initWithModal:YES];
    UiTNavViewController *navViewController = [[UiTNavViewController alloc] initWithRootViewController:favoritesViewController];
    [self presentViewController:navViewController animated:YES completion:nil];
}

-(void)openSearchModal {    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end