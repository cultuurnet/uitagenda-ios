//
//  UiTLinkLabel.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "TTTAttributedLabel.h"

@interface UiTLinkLabel : TTTAttributedLabel <TTTAttributedLabelDelegate>

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text;

-(NSString *)createPhoneNumber:(NSString *)contactItem;

@end