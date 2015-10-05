//
//  UiTBaseTableViewController.m
//  UiTagenda
//
//  Created by Robbe Vandecasteele on 28/09/15.
//  Copyright © 2015 Cultuurnet. All rights reserved.
//

#import "UiTBaseTableViewController.h"

@interface UiTBaseTableViewController ()

@end

@implementation UiTBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    if (!TARGETED_DEVICE_IS_IPAD) {
        self.navigationItem.leftBarButtonItem = [self showBarButtonWithType:UIBarButtonItemTypeList];
    }
    
    [self.navigationItem setRightBarButtonItems:@[ [self showBarButtonWithType:UIBarButtonItemTypeFavorite], [self showBarButtonWithType:UIBarButtonItemTypeSearch] ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController: (UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    //  Force master view to show in portrait and landscape
    return NO;
}

@end