//
//  ArrayDataSource.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ConfigureCellBlock)(id cell, id item);

@interface ArrayDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSArray *items;

-(id)initWithItems:(NSArray *)items
    cellIdentifier:(NSString *)identifier
configureCellBlock:(ConfigureCellBlock) configureCellBlock;

@end
