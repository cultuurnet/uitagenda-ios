//
//  UIViewController+UIBarButtonItems.h
//  UiTagenda
//
//  Created by Robbe Vandecasteele on 28/09/15.
//  Copyright © 2015 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UIBarButtonItemTypeList = 0,
    UIBarButtonItemTypeClose,
    UIBarButtonItemTypeFavorite,
    UIBarButtonItemTypeSearch
} UIBarButtonItemType;

@interface UIViewController (UIBarButtonItems)
- (UIBarButtonItem *)showBarButtonWithType:(UIBarButtonItemType)barButtonItemType;
@end