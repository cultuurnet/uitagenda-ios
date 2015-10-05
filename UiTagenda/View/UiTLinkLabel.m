//
//  UiTLinkLabel.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 29/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "UiTLinkLabel.h"

@implementation UiTLinkLabel

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
        self.linkAttributes = @{(id)kCTForegroundColorAttributeName: REDCOLOR,
                                (id)kCTUnderlineStyleAttributeName : @(kCTUnderlineStyleNone)
                                };
        self.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName: SLIDEMENUCOLOR,
                                      (id)kCTUnderlineStyleAttributeName: @(kCTUnderlineStyleNone)
                                      };
        self.enabledTextCheckingTypes = NSTextCheckingAllTypes;
        self.numberOfLines = 0;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.delegate = self;
        self.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:14];
        self.textColor = TITLECOLOR;
        self.text = text;
        [self sizeToFit];
    }
    return self;
}

//-(NSString *)createPhoneNumber:(NSString *)contactItem {
//    NSString *phoneNumber = [contactItem stringByReplacingOccurrencesOfString:@"/" withString:@""];
//    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@":" withString:@""];
//    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
//    return phoneNumber;
//}

#pragma mark - TTTAttributedLabel Delegated methods

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]]]];
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