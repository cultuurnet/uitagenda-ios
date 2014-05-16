//
//  UiTSearchQueriesViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "UiTBaseViewController.h"

@interface UiTSearchQueriesViewController : UiTBaseViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end