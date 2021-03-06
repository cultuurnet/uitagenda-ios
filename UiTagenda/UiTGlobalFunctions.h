//
//  UiTGlobalFunctions.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 5/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UiTGlobalFunctions : NSObject

+ (id)sharedInstance;

-(CALayer *)createBorderWithX:(CGFloat)x withY:(CGFloat)y withWidth:(CGFloat)width withHeight:(CGFloat)height withColor:(UIColor *)color;
-(void)trackGoogleAnalyticsWithValue:(NSString *)name;

-(UIButton *)createFavoriteOrShareButton:(NSString *)title;

-(UIFont *)customRegularFontWithSize:(CGFloat)fontSize;
-(UIFont *)customBoldFontWithSize:(CGFloat)fontSize;

@end