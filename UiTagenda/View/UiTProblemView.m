//
//  UiTProblemView.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 9/01/14.
//  Copyright (c) 2014 Cultuurnet. All rights reserved.
//

#import "UiTProblemView.h"

#define sizeProblemImageView 100

@interface UiTProblemView ()

@property (strong, nonatomic) UIImageView *problemImageView;

@end

@implementation UiTProblemView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupImage];
        [self setupLabel];
    }
    return self;
}

- (void) setupImage {
    _problemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CENTER_IN_PARENT_X(self, sizeProblemImageView), 0, sizeProblemImageView, sizeProblemImageView)];
    _problemImageView.image = [UIImage imageNamed:@"problemsmiley"];
    _problemImageView.backgroundColor = TABLEVIEWCOLOR;
    [self addSubview:_problemImageView];
}

- (void)setupLabel {
    _problemLabel = [[UILabel alloc] initWithFrame:CGRectMake(CENTER_IN_PARENT_X(self, 250), BOTTOM(_problemImageView), 250, 100)];
    _problemLabel.numberOfLines = 3;
    _problemLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
    _problemLabel.textAlignment = NSTextAlignmentCenter;
    _problemLabel.textColor = [UIColor lightGrayColor];
    _problemLabel.backgroundColor = TABLEVIEWCOLOR;
    [self addSubview:_problemLabel];
}

@end