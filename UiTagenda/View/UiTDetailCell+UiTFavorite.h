//
//  UiTDetailCell+UiTFavorite.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "UiTDetailCell.h"

@interface UiTDetailCell (UiTFavorite)

-(void)configureForEvent:(UiTEvent *)event withAllEvents:(NSMutableArray *)allEvents;

@end