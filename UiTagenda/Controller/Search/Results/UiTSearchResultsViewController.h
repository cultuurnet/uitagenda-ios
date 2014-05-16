//
//  UiTSearchResultsViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface UiTSearchResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

-(id)initWithSearchTerm:(NSString *)searchTerm
    withCurrentLocation:(BOOL)currentLocation
             withRadius:(NSString *)radius
               withWhen:(NSString *)when
              withWhere:(NSMutableDictionary *)where
               withWhat:(NSMutableDictionary *)what
      withExtraCriteria:(NSMutableDictionary *)extraCriteria
         withSavedQuery:(BOOL)alreadySaved;

@end