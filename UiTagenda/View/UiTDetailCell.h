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
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
-(void)setEvent:(UiTEvent *)event;
@end