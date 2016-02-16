//
//  NSDate+UiTDate.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 17/01/16.
//  Copyright © 2016 Cultuurnet. All rights reserved.
//

#import "NSDate+UiTDate.h"

@implementation NSDate (UiTDate)

- (NSString *)getStringFromDateWithFormat:(NSString *)format {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setLocale:[NSLocale currentLocale]];
    if (format.length <= 0) {
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
    } else {
        [dateFormat setDateFormat:format];
    }
    
    return self == nil ? @"" : [dateFormat stringFromDate:self];
}


@end
