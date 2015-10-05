//
//  UiTSearchResultsViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UiTBaseTableViewController.h"

@interface UiTSearchResultsViewController : UiTBaseTableViewController <UIAlertViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

- (void)setSearchTerm:(NSString *)searchTerm
  withCurrentLocation:(BOOL)currentLocation
           withRadius:(NSString *)radius
             withWhen:(NSString *)when
            withWhere:(NSMutableDictionary *)where
             withWhat:(NSMutableDictionary *)what
    withExtraCriteria:(NSMutableDictionary *)extraCriteria
       withSavedQuery:(BOOL)alreadySaved;
@end