//
//  UiTSearchQueriesViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "UiTBaseTableViewController.h"

@interface UiTSearchQueriesViewController : UiTBaseTableViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end