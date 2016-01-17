//
//  UiTGlobalFunctions.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 5/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTGlobalFunctions.h"

@implementation UiTGlobalFunctions

+ (id)sharedInstance {
    static dispatch_once_t onceToken = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (CALayer *)createBorderWithX:(CGFloat)x withY:(CGFloat)y withWidth:(CGFloat)width withHeight:(CGFloat)height withColor:(UIColor *)color {
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(x, y, width, height);
    border.backgroundColor = color.CGColor;
    return border;
}

- (UIButton *)createFavoriteOrShareButton:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Normal", [title lowercaseString]]] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Selected", [title lowercaseString]]] forState:UIControlStateSelected];
    [button setTitle:NSLocalizedString(title, @"") forState:UIControlStateNormal];
    [button.titleLabel setFont: [UIFont customBoldFontWithSize:17]];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 0.0f)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 8.0f, 0.0f, 0.0f)];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setBackgroundColor:[UIColor clearColor]];

    return button;
}

@end