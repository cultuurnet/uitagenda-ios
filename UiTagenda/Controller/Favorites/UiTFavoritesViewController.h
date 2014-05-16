//
//  UiTFavoritesViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UiTBaseViewController.h"

@interface UiTFavoritesViewController : UiTBaseViewController <NSFetchedResultsControllerDelegate>

-(id)initWithModal:(BOOL)modal;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end