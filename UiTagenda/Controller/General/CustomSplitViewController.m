//
//  CustomSplitViewController.m
//  UiTagenda
//
//  Created by Robbe Vandecasteele on 16/09/15.
//  Copyright (c) 2015 Cultuurnet. All rights reserved.
//

#import "CustomSplitViewController.h"

#define SPLIT_WIDTH 220

@interface CustomSplitViewController ()

@end

@implementation CustomSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    UIViewController *masterViewController = [self.viewControllers objectAtIndex:0];
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];
    
    if (detailViewController.view.frame.origin.x > 0.0) {
        
        CGRect masterViewFrame = masterViewController.view.frame;
        CGFloat deltaX = masterViewFrame.size.width - SPLIT_WIDTH;
        masterViewFrame.size.width -= deltaX;
        masterViewController.view.frame = masterViewFrame;
        
        CGRect detailViewFrame = detailViewController.view.frame;
        detailViewFrame.origin.x -= deltaX + 1;
        detailViewFrame.size.width += deltaX + 1;
        detailViewController.view.frame = detailViewFrame;

        [masterViewController.view setNeedsLayout];
        [detailViewController.view setNeedsLayout];
    }
}

@end