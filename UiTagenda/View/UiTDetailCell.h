//
//  UiTDetailCell.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UiTEvent.h"

@interface UiTDetailCell : UITableViewCell

@property (nonatomic, strong) UiTEvent *event;

@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic) UIButton *favoriteButton;
@property (strong, nonatomic) UIButton *shareButton;

@property (strong, nonatomic) UILabel *distanceLabel;

-(void)setEvent:(UiTEvent *)event;



@end