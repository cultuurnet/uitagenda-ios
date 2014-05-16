//
//  UiTSearchWhatViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 5/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UiTSearchWhatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

-(id)initWithExtensiveSearch:(BOOL)extensiveSearch andValue:(NSMutableDictionary *)values;

@end
