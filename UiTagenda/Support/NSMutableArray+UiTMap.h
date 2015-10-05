//
//  NSMutableArray+UiTMap.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (UiTMap)

-(NSMutableArray *)UiT_map:(id (^)(id inputItem))transformBlock;

@end
