//
//  UiTContainerViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UiTContainerViewController : UIViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)switchViewController:(UIViewController *)viewController;

- (UIViewController *)getContentViewControllers;

@end

@interface UIViewController (ProjectContainer)

@property (nonatomic, readonly) UiTContainerViewController *projectContainer;


@end