//
//  UiTSearchFilterViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UiTBaseTableViewController.h"
#import "UiTSearchWhereViewController.h"
#import "UiTSearchRadiusViewController.h"
#import "UiTSearchWhenViewController.h"
#import "UiTSearchWhatViewController.h"

@interface UiTSearchFilterViewController : UiTBaseTableViewController <UiTSearchRadiusDelegate, UiTSearchWhenDelegate, UitSearchWhereDelegate, UITextFieldDelegate, UitSearchWhatDelegate>

@end