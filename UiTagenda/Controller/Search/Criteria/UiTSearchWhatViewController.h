//
//  UiTSearchWhatViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 5/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UitSearchWhatDelegate <NSObject>
- (void)setWhatValue:(NSMutableDictionary *)values;
@end

@interface UiTSearchWhatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>
- (id)initWithExtensiveSearch:(BOOL)extensiveSearch andValue:(NSMutableDictionary *)values;
@property (strong, nonatomic) NSMutableDictionary *searchSelectedCriteria;
@property (weak, nonatomic) id<UitSearchWhatDelegate> delegate;
@property (nonatomic) BOOL extensiveSearch;
@end