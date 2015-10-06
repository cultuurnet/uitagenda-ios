//
//  UiTSearchWhereViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 6/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UitSearchWhereDelegate <NSObject>
- (void)setWhereValue:(NSMutableArray *)values;
@end
@interface UiTSearchWhereViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>
- (id)initWithValue:(NSMutableArray *)selectedValues;
@property (weak, nonatomic) id<UitSearchWhereDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *values;
@property (strong, nonatomic) NSMutableArray *selectedValues;
@end