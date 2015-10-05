//
//  UiTMenu.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTMenu.h"

@implementation UiTMenu

+ (id)sharedInstance {
    static NSArray *__sharedInstance;
    
    if (__sharedInstance == nil) {
        __sharedInstance = @[
                             @{
                                 kMenuId: @"HOME",
                                 kMenuTitle: NSLocalizedString(@"HOME", ""),
                                 kMenuViewController: @"UiTHomeViewController",
                                 kStoryboardTitle: @"Home",
                                 kMenuViewControllerIdentifier: @"homeVC"
                                 },
                             @{
                                 kMenuId: @"SEARCH",
                                 kMenuTitle: NSLocalizedString(@"SEARCH", ""),
                                 kMenuViewController: @"UiTSearchFilterViewController",
                                 kStoryboardTitle: @"Search"
                                 },
                             @{
                                 kMenuId: @"FAVORITES",
                                 kMenuTitle: NSLocalizedString(@"FAVORITES", ""),
                                 kMenuViewController: @"UiTFavoritesViewController",
                                 kStoryboardTitle: @"Favorites"
                                 },
                             @{
                                 kMenuId: @"SEARCHQUERIES",
                                 kMenuTitle: NSLocalizedString(@"SEARCHQUERIES", ""),
                                 kMenuViewController: @"UiTSearchQueriesViewController",
                                 kStoryboardTitle: @"MySearch"
                                 },
                             @{
                                 kMenuId: @"ABOUT",
                                 kMenuTitle: NSLocalizedString(@"ABOUT", ""),
                                 kMenuViewController: @"UiTAboutViewController",
                                 kStoryboardTitle: @"About",
                                 kMenuViewControllerIdentifier: @"aboutVC"
                                 }
                             ];
    }
    return __sharedInstance;
}

@end