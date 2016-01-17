//
//  UIFont+UiTFont.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 17/01/16.
//  Copyright © 2016 Cultuurnet. All rights reserved.
//

#import "UIFont+UiTFont.h"

@implementation UIFont (UiTFont)

+ (UIFont *)customRegularFontWithSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"PTSans-Narrow" size:fontSize];
}

+ (UIFont *)customBoldFontWithSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"PTSans-NarrowBold" size:fontSize];
}

@end
