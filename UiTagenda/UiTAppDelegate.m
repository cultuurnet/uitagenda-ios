//
//  UiTAppDelegate.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTAppDelegate.h"
#import "UiTHomeViewController.h"
#import "UiTMenuViewController.h"
#import "UiTContainerViewController.h"
#import "UiTNavViewController.h"
#import "CustomSplitViewController.h"
#import "UiTSearchQueriesViewController.h"
#import "GoogleAnalyticsTracker.h"

#import <NVSlideMenuController/NVSlideMenuController.h>

@implementation UiTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
#ifdef NEWRELICTOKEN
    [NRLogger setLogLevels:NRLogLevelNone];
    [NewRelicAgent startWithApplicationToken:NEWRELICTOKEN];
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = BACKGROUNDCOLOR;
    [self.window makeKeyAndVisible];
    
    [self setupGoogleAnalytics];

    UiTContainerViewController *containerVC = [[UiTContainerViewController alloc] init];
    containerVC = [[UiTContainerViewController alloc] initWithRootViewController:[containerVC getContentViewControllers]];
    
    self.window.rootViewController = containerVC;
    
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
    [[GAI sharedInstance] trackerWithTrackingId:googleTrackerID];
}

@end
