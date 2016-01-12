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
                                 kMenuViewControllerIdentifier: @"homeVC",
                                 kMenuIcon: @"nav_marker"
                                 },
                             @{
                                 kMenuId: @"SEARCH",
                                 kMenuTitle: NSLocalizedString(@"SEARCH", ""),
                                 kMenuViewController: @"UiTSearchFilterViewController",
                                 kStoryboardTitle: @"Search",
                                 kMenuIcon: @"nav_search"
                                 },
                             @{
                                 kMenuId: @"FAVORITES",
                                 kMenuTitle: NSLocalizedString(@"FAVORITES", ""),
                                 kMenuViewController: @"UiTFavoritesViewController",
                                 kStoryboardTitle: @"Favorites",
                                 kMenuIcon: @"nav_favorite"
                                 },
                             @{
                                 kMenuId: @"SEARCHQUERIES",
                                 kMenuTitle: NSLocalizedString(@"SEARCHQUERIES", ""),
                                 kMenuViewController: @"UiTSearchQueriesViewController",
                                 kStoryboardTitle: @"MySearch",
                                 kMenuIcon: @"nav_folder"
                                 },
                             @{
                                 kMenuId: @"ABOUT",
                                 kMenuTitle: NSLocalizedString(@"ABOUT", ""),
                                 kMenuViewController: @"UiTAboutViewController",
                                 kStoryboardTitle: @"About",
                                 kMenuViewControllerIdentifier: @"aboutVC",
                                 kMenuIcon: @"nav_info"
                                 }
                             ];
    }
    return __sharedInstance;
}

@end