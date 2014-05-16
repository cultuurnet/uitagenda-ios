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

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *eventTypeLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *cityLabel;

@property (strong, nonatomic) UIImageView *imageViewEvent;
@property (strong, nonatomic) UIImageView *imageViewLabelKids;

@property (strong, nonatomic) UIView *extrasView;

@property (strong, nonatomic) NSString *imageURL;

@end

@implementation UiTDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = BACKGROUNDCOLOR;
        
        [self setupContainerView];
        
        self.imageViewEvent = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 82, 98)];
        self.imageViewLabelKids = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 82, 98)];
        self.imageViewLabelKids.image = [UIImage imageNamed:@"kids_cell"];
        self.imageViewLabelKids.hidden = YES;
        //self.imageViewEvent.contentMode = UIViewContentModeScaleAspectFit;
        [self.containerView addSubview:self.imageViewEvent];
        [self.containerView addSubview:self.imageViewLabelKids];
        
        
        
        [self setupTitleLabel];
        [self setupeventTypeLabel];
        [self setupLocationLabel];
        [self setupcityLabel];
        
        [self setupDistanceLabel];
        
        //        [self setupExtrasView];
        
        [self setupFavoriteButton];
        [self setupShareButton];
        
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _eventTypeLabel.backgroundColor = [UIColor whiteColor];
        _locationLabel.backgroundColor = [UIColor whiteColor];
        _cityLabel.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.containerView];
    }
    return self;
}

- (void)setupContainerView {
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, WIDTH(self) - 20, 100)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    //    [self.containerView.layer setCornerRadius:3.0f];
    [self.containerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.containerView.layer setShadowOpacity:0.2];
    //    [self.containerView.layer setShadowRadius:1.0f];
    self.containerView.layer.shadowOffset = CGSizeMake(0, 0);
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.containerView.layer.bounds].CGPath;
}

- (void)setupTitleLabel {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(RIGHT(self.imageViewEvent) + padding,
                                                                5,
                                                                WIDTH(self.containerView) - WIDTH(self.imageViewEvent) - padding * 2,
                                                                20)];
    self.titleLabel.font = [[UiTGlobalFunctions sharedInstance] customBoldFontWithSize:14];
    self.titleLabel.textColor = REDCOLOR;
    [self.containerView addSubview:self.titleLabel];
}

- (void)setupeventTypeLabel {
    self.eventTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(RIGHT(self.imageViewEvent) + padding,
                                                               BOTTOM(self.titleLabel) + 3,
                                                               WIDTH(self.containerView) - WIDTH(self.imageViewEvent) - padding * 2,
                                                               20)];
    self.eventTypeLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:13];
    self.eventTypeLabel.textColor = DATECOLOR;
    self.eventTypeLabel.highlightedTextColor = [UIColor whiteColor];
    [self.containerView addSubview:self.eventTypeLabel];
}

- (void)setupLocationLabel {
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(RIGHT(self.imageViewEvent) + padding,
                                                                   BOTTOM(self.eventTypeLabel) + 3,
                                                                   WIDTH(self.containerView) - WIDTH(self.imageViewEvent) - padding * 2,
                                                                   20)];
    self.locationLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:13];
    self.locationLabel.textColor = LOCATIONCOLOR;
    self.locationLabel.highlightedTextColor = [UIColor whiteColor];
    [self.containerView addSubview:self.locationLabel];
}

-(void)setupcityLabel {
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(RIGHT(self.imageViewEvent) + padding,
                                                               BOTTOM(self.locationLabel) + 3,
                                                               WIDTH(self.containerView) - WIDTH(self.imageViewEvent) - padding * 2,
                                                               20)];
    self.cityLabel.font = [[UiTGlobalFunctions sharedInstance] customBoldFontWithSize:14];
    self.cityLabel.textColor = CITYCOLOR;
    self.cityLabel.highlightedTextColor = [UIColor whiteColor];
    [self.containerView addSubview:self.cityLabel];
}

-(void)setupDistanceLabel {
    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(RIGHT(self.cityLabel) + padding, Y(self.cityLabel), 30, 20)];
    self.distanceLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:14];
    self.distanceLabel.textColor = [UIColor lightGrayColor];
    self.distanceLabel.highlightedTextColor = [UIColor whiteColor];
    [self.containerView addSubview:self.distanceLabel];
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
    [self.containerView addSubview:self.extrasView];
}

- (void)setupFavoriteButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:[UIImage imageNamed:@"favoriteNormal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"favoriteSelected"] forState:UIControlStateSelected];
    
    self.favoriteButton = button;
    self.favoriteButton.backgroundColor = [UIColor whiteColor];
    [button setBackgroundColor:[UIColor whiteColor]];
    
    [self.favoriteButton setFrame:CGRectMake(RIGHT(self.containerView) - 45, BOTTOM(self.containerView) - 40, 35, 35)];
    [self.containerView addSubview:self.favoriteButton];
}

- (void)setupShareButton {
    self.shareButton = [[UiTGlobalFunctions sharedInstance] createFavoriteOrShareButton:@"SHARE"];
    [self.shareButton setFrame:CGRectMake(WIDTH(self.extrasView)/2, 0, WIDTH(self.extrasView)/2, HEIGHT(self.extrasView))];
    [self.extrasView addSubview:self.shareButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setEvent:(UiTEvent *)event {
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