//
//  UiTDetailCell.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTDetailCell.h"
#import "UIImageView+AFNetworking.h"
#import "UiTEvent.h"
#import "UitagendaDataModel.h"
#import "UiTFavorite.h"

#define padding 10

@interface UiTDetailCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewEvent;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLabelKids;

@property (strong, nonatomic) UIView *extrasView;

@property (strong, nonatomic) NSString *imageURL;

@end

@implementation UiTDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = BACKGROUNDCOLOR;
        [self setupContainerView];
        [self setupTitleLabel];
        [self setupeventTypeLabel];
        [self setupLocationLabel];
        [self setupcityLabel];
        [self setupDistanceLabel];
//      [self setupExtrasView];
        [self setupFavoriteButton];
        [self setupShareButton];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = BACKGROUNDCOLOR;
        
        [self setupContainerView];
        [self setupTitleLabel];
        [self setupeventTypeLabel];
        [self setupLocationLabel];
        [self setupcityLabel];
        [self setupDistanceLabel];
        [self setupFavoriteButton];
        [self setupShareButton];
    }
    return self;
}

- (void)setupContainerView {
//        [self.containerView.layer setCornerRadius:3.0f];
//    [self.containerView.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.containerView.layer setShadowOpacity:0.2];
//    //    [self.containerView.layer setShadowRadius:1.0f];
//    self.containerView.layer.shadowOffset = CGSizeMake(0, 0);
//    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.containerView.layer.bounds].CGPath;
    
    self.containerView.layer.masksToBounds = NO;
    self.containerView.layer.shadowOffset = CGSizeMake(-1, 1);
    self.containerView.layer.shadowRadius = 3;
    self.containerView.layer.shadowOpacity = 0.5;
    
    self.contentView.layer.masksToBounds = NO;
    self.contentView.layer.shadowOffset = CGSizeMake(-1, 1);
    self.contentView.layer.shadowRadius = 3;
    self.contentView.layer.shadowOpacity = 0.5;
}

- (void)setupTitleLabel {
    self.titleLabel.font = [[UiTGlobalFunctions sharedInstance] customBoldFontWithSize:14];
    self.titleLabel.textColor = REDCOLOR;
}

- (void)setupeventTypeLabel {
    self.eventTypeLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:13];
    self.eventTypeLabel.textColor = DATECOLOR;
    self.eventTypeLabel.highlightedTextColor = [UIColor whiteColor];
}

- (void)setupLocationLabel {
    self.locationLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:13];
    self.locationLabel.textColor = LOCATIONCOLOR;
    self.locationLabel.highlightedTextColor = [UIColor whiteColor];
}

- (void)setupcityLabel {
    self.cityLabel.font = [[UiTGlobalFunctions sharedInstance] customBoldFontWithSize:14];
    self.cityLabel.textColor = CITYCOLOR;
    self.cityLabel.highlightedTextColor = [UIColor whiteColor];
}

- (void)setupDistanceLabel {
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(RIGHT(self.cityLabel) + padding, Y(self.cityLabel), 30, 20)];
    self.distanceLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:14];
    self.distanceLabel.textColor = [UIColor lightGrayColor];
    self.distanceLabel.highlightedTextColor = [UIColor whiteColor];
}

- (void)setupExtrasView {
    self.extrasView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 40)];
    self.extrasView.backgroundColor = EXTRASVIEWCELLCOLOR;
    [self.extrasView.layer setCornerRadius:3.0f];
    
    [self.containerView.layer addSublayer:[[UiTGlobalFunctions sharedInstance] createBorderWithX:0
                                                                                           withY:TOP(self.extrasView) - 1
                                                                                       withWidth:WIDTH(self.extrasView)
                                                                                      withHeight:0.5
                                                                                       withColor:UIColorFromHex(0xE7E7E7)]];
//    [self.containerView addSubview:self.extrasView];
}

- (void)setupFavoriteButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:[UIImage imageNamed:@"favoriteNormal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"favoriteSelected"] forState:UIControlStateSelected];
    
    self.favoriteButton = button;
    self.favoriteButton.backgroundColor = [UIColor whiteColor];
    [button setBackgroundColor:[UIColor whiteColor]];
    
    [self.favoriteButton setFrame:CGRectMake(RIGHT(self.containerView) - 45, BOTTOM(self.containerView) - 40, 35, 35)];
//    [self.containerView addSubview:self.favoriteButton];
}

- (void)setupShareButton {
    self.shareButton = [[UiTGlobalFunctions sharedInstance] createFavoriteOrShareButton:@"SHARE"];
    [self.shareButton setFrame:CGRectMake(WIDTH(self.extrasView)/2, 0, WIDTH(self.extrasView)/2, HEIGHT(self.extrasView))];
    [self.extrasView addSubview:self.shareButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setEvent:(UiTEvent *)event {
    _event = event;
    
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    
    if (context) {
        UiTFavorite *fav = [UiTFavorite favoriteWithEventId:event.cdbid usingManagedObjectContext:context];
        [self.favoriteButton setSelected:(fav == nil ? NO : YES)];
    }
    
    if (_event.ageFrom != nil) {
        if ([event.ageFrom intValue] <= 11) {
            self.imageViewLabelKids.hidden = NO;
        }
        else {
            self.imageViewLabelKids.hidden = YES;
        }
    }
    else {
        self.imageViewLabelKids.hidden = YES;
    }
    
    if (_event.title != (id)[NSNull null]) {
        [self.titleLabel setText:_event.title];
    }
    
    /*if (_event.calendarSummary != (id)[NSNull null] && ![_event.calendarSummary isEqualToString:@""]) {
        [self.eventTypeLabel setText:_event.calendarSummary];
    }
    else {
        [self.eventTypeLabel setText:@"-"];
    }*/
    
    if ([_event.categories count] > 0) {
        self.eventTypeLabel.text = [_event.categories componentsJoinedByString:@", "];
    }
    else {
        self.eventTypeLabel.text = @"-";
    }
    
    if (_event.shortDescription != (id)[NSNull null]) {
        [self.locationLabel setText:_event.locationValue];
    }
    
    if (_event.place != (id)[NSNull null]) {
        [self.cityLabel setText:_event.city];
        [self.cityLabel sizeToFit];
        
        self.distanceLabel.frame = CGRectMake(RIGHT(self.cityLabel) + padding, Y(self.cityLabel), 30, 20);
    }
    
    if (![[NSString stringWithFormat:@"%@", _event.imageURL] isEqualToString:@""]) {
        [self.imageViewEvent setImageWithURL:_event.imageURL placeholderImage:[UIImage imageNamed:@"no-thumbnail"]];
    }
    else {
        [self.imageViewEvent setImage:[UIImage imageNamed:@"no-thumbnail"]];
    }
}

@end