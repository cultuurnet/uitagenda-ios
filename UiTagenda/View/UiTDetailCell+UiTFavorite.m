//
//  UiTDetailCell+UiTFavorite.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "UiTDetailCell+UiTFavorite.h"

@implementation UiTDetailCell (UiTFavorite)

- (void)configureForEvent:(UiTEvent *)event withAllEvents:(NSMutableArray *)allEvents {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.event = event;
    
    if (self.event.datePassed) {
        self.contentView.alpha = 0.5;
    }
    
    self.favoriteButton.tag = [allEvents indexOfObject:event];
}

@end