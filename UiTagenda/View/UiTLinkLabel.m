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
        self.font = [UIFont customRegularFontWithSize:14];
        self.textColor = TITLECOLOR;
        self.text = text;
        [self sizeToFit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
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
        self.font = [UIFont customRegularFontWithSize:14];
        self.textColor = TITLECOLOR;
        [self sizeToFit];
    }
    return self;
}

#pragma mark - TTTAttributedLabel Delegated methods

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]]]];
}

@end