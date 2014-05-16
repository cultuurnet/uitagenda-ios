//
//  UiTMenu.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTMenu.h"

@implementation UiTMenu

+(id)sharedInstance {
    static NSArray *__sharedInstance;
    
    if (__sharedInstance == nil) {
        __sharedInstance = @[
                             @{@"id": @"HOME", @"title": NSLocalizedString(@"HOME", ""), @"view": @"UiTHomeViewController"},
                             @{@"id": @"SEARCH", @"title": NSLocalizedString(@"SEARCH", ""), @"view": @"UiTSearchFilterViewController"},
                             @{@"id": @"FAVORITES", @"title": NSLocalizedString(@"FAVORITES", ""), @"view": @"UiTFavoritesViewController"},
                             @{@"id": @"SEARCHQUERIES", @"title": NSLocalizedString(@"SEARCHQUERIES", ""), @"view": @"UiTSearchQueriesViewController"},
                             @{@"id": @"ABOUT", @"title": NSLocalizedString(@"ABOUT", ""), @"view": @"UiTAboutViewController"}
                             ];
    }
    return __sharedInstance;
}

@end