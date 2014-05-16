//
//  UiTNavViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTNavViewController.h"

@interface UiTNavViewController ()

@end

@implementation UiTNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self customizeNavBar];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)customizeNavBar {
    [self.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:21], NSFontAttributeName, nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end