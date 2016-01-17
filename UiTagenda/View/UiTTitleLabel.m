//
//  UiTTitleLabel.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "UiTTitleLabel.h"

@implementation UiTTitleLabel

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfLines = 0;
        self.font = [UIFont customBoldFontWithSize:16];
        self.textColor = [UIColor blackColor];
        self.text = title;
        [self sizeToFit];
    }
    return self;
}

//-(void)setText:(NSString *)text {
//    self.text = text;
//    [self sizeToFit];
//}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end