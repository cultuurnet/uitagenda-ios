//
//  UiTFavoritesViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UiTBaseTableViewController.h"

@interface UiTFavoritesViewController : UiTBaseTableViewController <NSFetchedResultsControllerDelegate>

- (id)initWithModal:(BOOL)modal;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL modal;
@end