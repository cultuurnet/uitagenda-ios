//
//  UiTInfoLabel.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "UiTInfoLabel.h"

@implementation UiTInfoLabel

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfLines = 0;
        self.textColor = [UIColor blackColor];
        self.font = [UIFont customRegularFontWithSize:14];
        self.text = text;
        [self sizeToFit];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end