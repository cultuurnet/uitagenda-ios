//
//  GoogleAnalyticsTracker.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 8/10/15.
//  Copyright © 2015 Cultuurnet. All rights reserved.
//

#import "GoogleAnalyticsTracker.h"

@implementation GoogleAnalyticsTracker

+ (id)sharedInstance {
    static dispatch_once_t onceToken = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (void)trackGoogleAnalyticsWithValue:(NSString *)value {
    [[[GAI sharedInstance] defaultTracker] set:kGAIDescription value:value];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createScreenView] build]];
}

@end
