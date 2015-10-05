//
//  UiTDetailContainerViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 21/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UiTEvent.h"

@interface UiTDetailContainerViewController : UIViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)switchViewController:(UiTEvent *)event andResultsArr:(NSArray *)eventsArray;

@end

@interface UIViewController (DetailContainer)
@property (nonatomic, readonly) UiTDetailContainerViewController *detailContainer;


@end