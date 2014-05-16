//
//  UiTAppDelegate.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTAppDelegate.h"
#import "NVSlideMenuController/NVSlideMenuController.h"
#import "UiTHomeViewController.h"
#import "UiTMenuViewController.h"
#import "UiTContainerViewController.h"
#import "UiTNavViewController.h"

#import "UiTSearchQueriesViewController.h"

@implementation UiTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifdef NEWRELICTOKEN
    [NRLogger setLogLevels:NRLogLevelNone];
    [NewRelicAgent startWithApplicationToken:NEWRELICTOKEN];
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = BACKGROUNDCOLOR;
    [self.window makeKeyAndVisible];
    
    [self setupGoogleAnalytics];
    
    UIViewController *viewController = nil; 
    
    UiTHomeViewController *homeViewController = [[UiTHomeViewController alloc] initWithNibName:nil bundle:nil];
    UiTMenuViewController *menuViewController = [[UiTMenuViewController alloc] initWithNibName:nil bundle:nil];
    
    UiTNavViewController *navigationViewController = [[UiTNavViewController alloc] initWithNibName:nil bundle:nil];
    [navigationViewController setViewControllers:[[NSArray alloc] initWithObjects:homeViewController, nil]];
     
    viewController = [[NVSlideMenuController alloc] initWithMenuViewController:menuViewController andContentViewController:navigationViewController];
    
    UiTContainerViewController *containerViewController = [[UiTContainerViewController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = containerViewController;
    
    [self fixLagFreeTextField];
    
    return YES;
}

- (void)fixLagFreeTextField {
    // Fix super slow lag/delay on initial keyboard animation of UITextField
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
}

-(void)setupGoogleAnalytics {
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].dispatchInterval = 10;
    [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALYTICS];
}

@end