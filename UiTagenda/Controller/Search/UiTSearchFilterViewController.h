//
//  UiTSearchFilterViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UiTBaseViewController.h"

#import "UiTSearchWhereViewController.h"
#import "UiTSearchRadiusViewController.h"
#import "UiTSearchWhenViewController.h"
#import "UiTSearchWhatViewController.h"

@interface UiTSearchFilterViewController : UiTBaseViewController <UITableViewDelegate, UITableViewDataSource, UiTSearchRadiusDelegate, UiTSearchWhenDelegate, UitSearchWhereDelegate, UITextFieldDelegate>

@end