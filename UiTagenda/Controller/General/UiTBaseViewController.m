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

@interface UiTBaseViewController ()

@end

@implementation UiTBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    if (!TARGETED_DEVICE_IS_IPAD) {
        self.navigationItem.leftBarButtonItem = [self showBarButtonWithType:UIBarButtonItemTypeList];
    }
    
    [self.navigationItem setRightBarButtonItems:@[ [self showBarButtonWithType:UIBarButtonItemTypeFavorite], [self showBarButtonWithType:UIBarButtonItemTypeSearch] ]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController: (UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    //  Force master view to show in portrait and landscape
    return NO;
}

@end