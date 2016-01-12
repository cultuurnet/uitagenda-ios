//
//  UiTMenu.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kMenuId = @"id";
static NSString *kMenuTitle = @"title";
static NSString *kMenuViewController = @"viewController";
static NSString *kStoryboardTitle = @"storyboardTitle";
static NSString *kMenuViewControllerIdentifier = @"vcIdentifier";
static NSString *kMenuIcon = @"menuIcon";

@interface UiTMenu : NSObject

+(id)sharedInstance;

@end