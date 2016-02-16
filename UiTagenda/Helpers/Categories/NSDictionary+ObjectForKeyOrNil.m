//
//  NSDictionary+ObjectForKeyOrNil.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 16/01/16.
//  Copyright © 2015 Cultuurnet. All rights reserved.
//

#import "NSDictionary+ObjectForKeyOrNil.h"

@implementation NSDictionary (ObjectForKeyOrNil)

- (id)objectForKeyOrNil:(id)key {
    id val = [self objectForKey:key];
    if ([val isEqual:[NSNull null]]) {
        return nil;
    }

    return val;
}

@end
