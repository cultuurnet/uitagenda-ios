//
//  ArrayDataSource.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "ArrayDataSource.h"
#import "UiTDetailCell.h"

@interface ArrayDataSource ()

@property (copy, nonatomic) NSString *cellIdentifier;
@property (copy, nonatomic) ConfigureCellBlock cellBlock;

@end

@implementation ArrayDataSource

-(id)initWithItems:(NSArray *)items
    cellIdentifier:(NSString *)identifier
configureCellBlock:(ConfigureCellBlock)configureCellBlock {
    self = [super init];
    if (self) {
        self.items = items;
        self.cellIdentifier = identifier;
        self.cellBlock = configureCellBlock;
    }
    return self;
}

-(id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.items[indexPath.row];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = (id)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    if (cell == nil) {
        cell = [[UiTDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    id item = [self itemAtIndexPath:indexPath];
    self.cellBlock(cell, item);
    return cell;
}

@end