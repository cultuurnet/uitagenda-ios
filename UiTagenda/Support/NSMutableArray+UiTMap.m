//
//  NSMutableArray+UiTMap.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "NSMutableArray+UiTMap.h"

@implementation NSMutableArray (UiTMap)

-(NSMutableArray *)UiT_map:(id (^)(id inputItem))transformBlock {
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:self.count];
    for (id item in self) {
        id newItem = transformBlock(item);
        [newArray addObject:newItem];
    }
    return newArray;
}

@end
