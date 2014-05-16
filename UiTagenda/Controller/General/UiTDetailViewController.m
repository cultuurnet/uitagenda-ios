//
//  UiTDetailViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTDetailViewController.h"
#import "UiTAPIClient.h"
#import "UiTEvent.h"
#import "UIImageView+AFNetworking.h"
#import "UiTFavoritesViewController.h"
#import "UiTNavViewController.h"
#import "UitagendaDataModel.h"
#import "UiTFavorite.h"

#import "UiTTitleLabel.h"
#import "UiTInfoLabel.h"
#import "UiTLinkLabel.h"

#define paddingTitle 10
#define paddingInfo 5
#define insetLeft 10
#define insetTop 10
#define padding 10
#define widthPadding insetLeft * 2

#define widthAllViews 300

@interface UiTDetailViewController ()

@property (strong, nonatomic) UiTEvent *event;
@property (strong, nonatomic) NSArray *eventsArray;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIButton *favoriteButton;
@property (strong, nonatomic) UIButton *shareButton;

@property (strong, nonatomic) UIButton *previousButton, *nextButton;

@property (nonatomic) NSInteger yOffset, eventIndex;

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIView *longDescriptionView;

@end

@implementation UiTDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(id)initWithEvent:(UiTEvent *)event andEventsArray:(NSArray *)eventsArray {
    self = [super init];
    if (self) {
        _event = event;
        _eventsArray = eventsArray;
    }
    return self;
}

- (void)viewDidLoad {
    _eventIndex = [self.eventsArray indexOfObject:_event];
    
    [self setupScrollView];
    [self setupEventView];
    
    self.title = NSLocalizedString(@"DETAIL", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"DETAIL", @"")];
}

-(void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), tableViewHeight)];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:self.scrollView];
    
    [self.view.layer addSublayer:[[UiTGlobalFunctions sharedInstance] createBorderWithX:0
                                                                                  withY:HEIGHT(self.view) - 104
                                                                              withWidth:WIDTH(self.view)
                                                                             withHeight:1
                                                                              withColor:UIColorFromHex(0xE7E7E7)]];
    
    [self setupFavoriteButton];
    [self setupShareButton];
    [self setupNextAndPrevious];
}

-(void)setupEventView {
    
    self.yOffset = 11;
    
    UIView *imageAndTitleView = [[UIView alloc] initWithFrame:CGRectMake(insetLeft, insetTop, widthAllViews, 400)];
    imageAndTitleView.backgroundColor = [UIColor whiteColor];
    
    // IMAGE
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, widthAllViews - 2, 250)];
    if (_event.imageURL != nil) {
        NSArray *splitURL = [[NSString stringWithFormat:@"%@", _event.imageURL] componentsSeparatedByString:@"?"];
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%i&height=%i&crop=auto", splitURL[0], (int)(WIDTH(self.view) - 20) * 2, 500]];
        [imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"no-thumbnail"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageAndTitleView addSubview:imageView];
        
        if (_event.ageFrom != nil) {
            if ([_event.ageFrom intValue] <= 11) {
                UIImageView *imageViewKids = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, widthAllViews - 2, 250)];
                imageViewKids.image = [UIImage imageNamed:@"kids"];
                [imageAndTitleView addSubview:imageViewKids];
            }
        }
        
        self.yOffset += (HEIGHT(imageView));
    }
    
    UILabel *titleLabel;
    
    // TITLE
    if (![_event.title isEqualToString:@""]){
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(insetLeft, self.yOffset, widthAllViews - widthPadding, 400)];
        titleLabel.text = _event.title;
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.font = [[UiTGlobalFunctions sharedInstance] customBoldFontWithSize:20];
        titleLabel.textColor = TITLECOLOR;
        titleLabel.numberOfLines = 0;
        [titleLabel sizeToFit];
        [imageAndTitleView addSubview:titleLabel];
        self.yOffset += HEIGHT(titleLabel) + paddingTitle;
    }
    
    UIImageView *categoryImageView;
    if ([_event.categories count] > 0) {
        categoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(insetLeft, self.yOffset + 1, 14, 14)];
        categoryImageView.image = [UIImage imageNamed:@"tagicon"];
        [imageAndTitleView addSubview:categoryImageView];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(RIGHT(categoryImageView) + 8, self.yOffset, 300, 400)];
        categoryLabel.text = [_event.categories componentsJoinedByString:@", "];
        categoryLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:14];
        categoryLabel.textColor = LOCATIONCOLOR;
        categoryLabel.numberOfLines = 0;
        [categoryLabel sizeToFit];
        [imageAndTitleView addSubview:categoryLabel];
        
        self.yOffset = BOTTOM(categoryLabel) + paddingTitle;
    }
    
    imageAndTitleView.frame = CGRectMake(insetLeft, insetTop, widthAllViews, self.yOffset);
    [self.scrollView addSubview:imageAndTitleView];
    
    UILabel *calendarLabel;
    UIView *calendarAndAddressView = [[UIView alloc] initWithFrame:CGRectMake(insetLeft, self.yOffset, widthAllViews, 400)];
    calendarAndAddressView.backgroundColor = UIColorFromHex(0xf1f1f1);
    
    UIImageView *calendarImageView;
    if (![_event.calendarSummary isEqualToString:@""]) {
        calendarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(insetLeft, insetTop, 20, 20)];
        calendarImageView.image = [UIImage imageNamed:@"calendaricon"];
        [calendarAndAddressView addSubview:calendarImageView];
        
        calendarLabel = [[UILabel alloc] initWithFrame:CGRectMake(RIGHT(calendarImageView) + 10, insetTop, widthAllViews - 40, 400)];
        calendarLabel.text = _event.calendarSummary;
        calendarLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
        calendarLabel.textColor = [UIColor blackColor];
        calendarLabel.numberOfLines = 0;
        [calendarLabel sizeToFit];
        [calendarAndAddressView addSubview:calendarLabel];
    }
    
    UIImageView *placeImageView;
    UIButton *placeButton;
    if (![_event.address isEqualToString:@""]) {
        placeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(insetLeft, BOTTOM(calendarLabel) + 10, 20, 20)];
        placeImageView.image = [UIImage imageNamed:@"locationicon"];
        [calendarAndAddressView addSubview:placeImageView];
        
        placeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [placeButton setFrame:CGRectMake(RIGHT(placeImageView) + 10, BOTTOM(calendarLabel) + 10, widthAllViews - 40, 400)];
        [placeButton setTitle:_event.address forState:UIControlStateNormal];
        [placeButton addTarget:self action:@selector(showRoute) forControlEvents:UIControlEventTouchUpInside];
        placeButton.titleLabel.numberOfLines = 0;
        [placeButton setTitleColor:REDCOLOR forState:UIControlStateNormal];
        placeButton.titleLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:13];
        [placeButton sizeToFit];
        [calendarAndAddressView addSubview:placeButton];
        self.yOffset += (HEIGHT(placeButton));
    }
    
    calendarAndAddressView.frame = CGRectMake(insetLeft, self.yOffset - 20, 300, BOTTOM(placeButton) + 1);
    
    [self.scrollView addSubview:calendarAndAddressView];
    
    self.yOffset = BOTTOM(calendarAndAddressView);
    
    UIView *shortDescriptionView = [[UIView alloc] initWithFrame:CGRectMake(insetLeft, self.yOffset + 1, 300, 400)];
    shortDescriptionView.backgroundColor = [UIColor whiteColor];
    
    UILabel *placeLabel;
    
    if (![_event.place isEqualToString:@""]) {
        placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(self.view) - widthPadding, 400)];
        placeLabel.text = _event.place;
        placeLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
        placeLabel.numberOfLines = 0;
        placeLabel.textColor = TITLECOLOR;
        [placeLabel sizeToFit];
        [shortDescriptionView addSubview:placeLabel];
    }
    
    UILabel *shortDescriptionLabel;
    if (_event.shortDescription != (id)[NSNull null] && ![_event.shortDescription isEqualToString:@"NB"]){
        shortDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(insetLeft, BOTTOM(placeLabel) + paddingTitle, WIDTH(shortDescriptionView) - widthPadding, 400)];
        shortDescriptionLabel.text = _event.shortDescription;
        shortDescriptionLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
        shortDescriptionLabel.textColor = TITLECOLOR;
        shortDescriptionLabel.numberOfLines = 0;
        [shortDescriptionLabel sizeToFit];
        [shortDescriptionView addSubview:shortDescriptionLabel];
    }
    
    shortDescriptionView.frame = CGRectMake(10, self.yOffset + 1, 300, HEIGHT(placeLabel) + HEIGHT(shortDescriptionLabel) + 40);
    
    [self.scrollView addSubview:shortDescriptionView];
    
    self.yOffset = BOTTOM(shortDescriptionView);
    
    if (![_event.organiser isEqualToString:@""]) {
        UIView *organiserView = [[UIView alloc] initWithFrame:CGRectMake(10, self.yOffset + 1, 300, 400)];
        organiserView.backgroundColor = [UIColor whiteColor];
        
        UiTTitleLabel *organiserTitle = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(self.view) - widthPadding, 400) andTitle:NSLocalizedString(@"ORGANISER", @"")];
        [organiserView addSubview:organiserTitle];
        
        UiTInfoLabel *organiserLabel = [[UiTInfoLabel alloc] initWithFrame:CGRectMake(insetLeft, BOTTOM(organiserTitle) + paddingTitle, WIDTH(self.view) - widthPadding, 400) andText:_event.organiser];
        [organiserView addSubview:organiserLabel];
        
        
        organiserView.frame = CGRectMake(10, BOTTOM(shortDescriptionView) + 1, 300, HEIGHT(organiserTitle) + HEIGHT(organiserLabel) + 50);
        self.yOffset = BOTTOM(organiserView);
        [self.scrollView addSubview:organiserView];
    }
    
    if ([_event.contactInfo count] > 0) {
        UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(10, self.yOffset + 1, 300, 400)];
        contactView.backgroundColor = [UIColor whiteColor];
        
        UiTTitleLabel *contactTitle   = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(contactView) - widthPadding, 400) andTitle:NSLocalizedString(@"CONTACT", @"")];
        [contactView addSubview:contactTitle];
        
        int yOffsetContact = BOTTOM(contactTitle) + paddingTitle;
        
        for (NSString *contactItem in _event.contactInfo) {
            for (NSString *contactItemInfo in [_event.contactInfo valueForKey:contactItem]) {
                UiTLinkLabel *contactLabel;
                if ([contactItem isEqualToString:@"phone"]) {
                    contactLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetContact, WIDTH(contactView) - widthPadding, 400) andText:[self createPhoneNumber:contactItemInfo]];
                }
                else {
                    contactLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetContact, WIDTH(contactView) - widthPadding, 400) andText:contactItemInfo];
                }
                
                [contactView addSubview:contactLabel];
                yOffsetContact += (HEIGHT(contactLabel) + 10);
            }
        }
        
        contactView.frame = CGRectMake(insetLeft, self.yOffset + 1, 300, HEIGHT(contactTitle) + yOffsetContact - 10);
        self.yOffset = BOTTOM(contactView);
        [self.scrollView addSubview:contactView];
    }
    
    if ([_event.contactReservationInfo count] > 0) {
        UIView *contactReservationView = [[UIView alloc] initWithFrame:CGRectMake(10, self.yOffset + 1, 300, 400)];
        contactReservationView.backgroundColor = [UIColor whiteColor];
        
        UiTTitleLabel *reservationTitle   = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(contactReservationView) - widthPadding, 400)
                                                                        andTitle:NSLocalizedString(@"RESERVATION", @"")];
        [contactReservationView addSubview:reservationTitle];
        
        int yOffsetReservationContact = BOTTOM(reservationTitle) + paddingTitle;
        
        for (NSString *contactItem in _event.contactReservationInfo) {
            for (NSString *contactItemInfo in [_event.contactReservationInfo valueForKey:contactItem]) {
                UiTLinkLabel *contactLabel;
                
                if ([contactItem isEqualToString:@"phone"]) {
                    contactLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetReservationContact, WIDTH(contactReservationView) - widthPadding, 400) andText:[self createPhoneNumber:contactItemInfo]];
                }
                else {
                    contactLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetReservationContact, WIDTH(contactReservationView) - widthPadding, 400) andText:contactItemInfo];
                }
                
                [contactReservationView addSubview:contactLabel];
                yOffsetReservationContact += (HEIGHT(contactLabel) + 10);
            }
        }
        contactReservationView.frame = CGRectMake(10, self.yOffset + 1, 300, HEIGHT(reservationTitle) + yOffsetReservationContact);
        self.yOffset = BOTTOM(contactReservationView);
        [self.scrollView addSubview:contactReservationView];
    }
    
    if (![_event.price isEqualToString:@""]) {
        UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(10, self.yOffset + 1, 300, 400)];
        priceView.backgroundColor = [UIColor whiteColor];
        
        UiTTitleLabel *priceTitle   = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(priceView) - widthPadding, 400) andTitle:NSLocalizedString(@"PRICE", @"")];
        [priceView addSubview:priceTitle];
        
        UiTInfoLabel *priceLabel;
        
        if ([_event.price isEqualToString:@"0"]) {
            priceLabel = [[UiTInfoLabel alloc] initWithFrame:CGRectMake(insetLeft, BOTTOM(priceTitle) + 10, WIDTH(self.view) - widthPadding, 400) andText:NSLocalizedString(@"FREE", @"")];
        }
        else {
            priceLabel = [[UiTInfoLabel alloc] initWithFrame:CGRectMake(insetLeft, BOTTOM(priceTitle) + 10, WIDTH(self.view) - widthPadding, 400) andText:[NSString stringWithFormat:@"€%@", _event.price]];
        }
        
        [priceView addSubview:priceLabel];
        
        UiTInfoLabel *priceDescriptionLabel;
        if (![_event.priceDescription isEqualToString:@""]) {
            priceDescriptionLabel = [[UiTInfoLabel alloc] initWithFrame:CGRectMake(insetLeft, BOTTOM(priceLabel) + 10, WIDTH(priceView) - widthPadding, 400) andText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"EXTRA INFO", @""), _event.priceDescription]];
            [priceView addSubview:priceDescriptionLabel];
            priceView.frame = CGRectMake(10, self.yOffset + 1, 300, BOTTOM(priceDescriptionLabel) + paddingTitle * 2);
        }
        else {
            priceView.frame = CGRectMake(10, self.yOffset + 1, 300, BOTTOM(priceLabel) + paddingTitle * 2);
        }
        
        self.yOffset = BOTTOM(priceView);
        [self.scrollView addSubview:priceView];
    }
    
    if ([_event.mediaInfo count] > 0) {
        UIView *mediaView = [[UIView alloc] initWithFrame:CGRectMake(10, self.yOffset + 1, 300, 400)];
        mediaView.backgroundColor = [UIColor whiteColor];
        
        UiTTitleLabel *mediaTitle   = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(mediaView) - widthPadding, 400) andTitle:NSLocalizedString(@"LINKS", @"")];
        [mediaView addSubview:mediaTitle];
        
        int yOffsetMedia = BOTTOM(mediaTitle) + paddingTitle;
        
        for (NSString *mediaInfo in _event.mediaInfo) {
            UiTLinkLabel *mediaLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetMedia, WIDTH(mediaView) - widthPadding, 400) andText:mediaInfo];
            [mediaView addSubview:mediaLabel];
            yOffsetMedia += (HEIGHT(mediaLabel) + 10);
        }
        mediaView.frame = CGRectMake(10, self.yOffset + 1, 300, yOffsetMedia + 20);
        self.yOffset = BOTTOM(mediaView);
        [self.scrollView addSubview:mediaView];
    }
    
    if ([_event.performers count] > 0) {
        UIView *performersView = [[UIView alloc] initWithFrame:CGRectMake(10, self.yOffset + 1, 300, 400)];
        performersView.backgroundColor = [UIColor whiteColor];
        
        UiTTitleLabel *performersTitle   = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(performersView) - widthPadding, 400) andTitle:NSLocalizedString(@"PERFORMERS", @"")];
        [performersView addSubview:performersTitle];
        
        int yOffsetPerformers = BOTTOM(performersTitle) + paddingTitle;
        
        for (NSArray *performer in _event.performers) {
            
            UiTInfoLabel *performerLabel;
            if ([performer valueForKeyPath:@"role"] != [NSNull null]) {
                performerLabel = [[UiTInfoLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetPerformers, WIDTH(performersView) - widthPadding, 400)
                                                             andText:[NSString stringWithFormat:@"%@ \nRol: %@\n", [performer valueForKeyPath:@"label.value"], [performer valueForKeyPath:@"role"]]];
            }
            else {
                performerLabel = [[UiTInfoLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetPerformers, WIDTH(performersView) - widthPadding, 400)
                                                             andText:[performer valueForKeyPath:@"label.value"]];
            }
            
            [performersView addSubview:performerLabel];
            yOffsetPerformers += (HEIGHT(performerLabel) + 5);
        }
        performersView.frame = CGRectMake(10, self.yOffset + 1, 300, yOffsetPerformers + 20);
        self.yOffset = BOTTOM(performersView);
        [self.scrollView addSubview:performersView];
    }
    
    if (![_event.longDescription isEqualToString:@""]) {
        _longDescriptionView = [[UIView alloc] initWithFrame:CGRectMake(10, self.yOffset + 1, 300, 20)];
        _longDescriptionView.backgroundColor = [UIColor whiteColor];
        
        UiTTitleLabel *longDescriptionTitle = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(self.view) - widthPadding, 400) andTitle:NSLocalizedString(@"LONG DESCRIPTION", @"")];
        [_longDescriptionView addSubview:longDescriptionTitle];
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, BOTTOM(longDescriptionTitle) + 5, 290, 20)];
        _webView.delegate = self;
        
        NSString *stringWithFont = [NSString stringWithFormat:@"<style type='text/css'>* { font-family: \"PT Sans Narrow\"; } </style>%@", _event.longDescription];
        [_webView loadHTMLString:stringWithFont baseURL:nil];
        [_longDescriptionView addSubview:_webView];
        
        _longDescriptionView.frame = CGRectMake(10, self.yOffset + 1, 300, BOTTOM(_webView) + 20);
        self.yOffset = BOTTOM(_longDescriptionView);
        [self.scrollView addSubview:_longDescriptionView];
    }
    
    self.scrollView.contentSize = CGSizeMake(WIDTH(self.view), self.yOffset + 10 + HEIGHT(_previousButton));
    
}

-(NSString *)createPhoneNumber:(NSString *)contactItem {
    NSString *phoneNumber = [contactItem stringByReplacingOccurrencesOfString:@"/" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@":" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
    return phoneNumber;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    CGRect frame = _webView.frame;
    CGSize fittingSize = [_webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    _webView.frame = frame;
    
    _longDescriptionView.frame = CGRectMake(10, TOP(_longDescriptionView), 300, BOTTOM(_webView));
    self.yOffset = BOTTOM(_longDescriptionView);
    self.scrollView.contentSize = CGSizeMake(WIDTH(self.view), self.yOffset + 10 + HEIGHT(_previousButton));
}

-(void)setupNextAndPrevious {
    _previousButton = [[UIButton alloc] initWithFrame:CGRectMake(0, HEIGHT(self.view) - 103, 41, 40)];
    _previousButton.backgroundColor = REDCOLOR;
    [_previousButton addTarget:self action:@selector(showPreviousEvent) forControlEvents:UIControlEventTouchUpInside];
    [_previousButton setImage:[UIImage imageNamed:@"backicon"] forState:UIControlStateNormal];
    _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(RIGHT(self.shareButton) - 1, HEIGHT(self.view) - 103, 41, 40)];
    _nextButton.backgroundColor = REDCOLOR;
    [_nextButton addTarget:self action:@selector(showNextEvent) forControlEvents:UIControlEventTouchUpInside];
    [_nextButton setImage:[UIImage imageNamed:@"forwardicon"] forState:UIControlStateNormal];
    
    [self.view addSubview:_previousButton];
    [self.view addSubview:_nextButton];
    
    if (_eventIndex == 0) {
        _previousButton.enabled = FALSE;
    }
    else {
        _previousButton.enabled = TRUE;
    }
    
    if (_eventIndex == [_eventsArray count] - 1) {
        _nextButton.enabled  = FALSE;
    }
    else {
        _nextButton.enabled = TRUE;
    }
    
    //self.yOffset += (HEIGHT(_previousButton));
}

-(void)showPreviousEvent {
    [self.detailContainer switchViewController:[_eventsArray objectAtIndex:_eventIndex - 1] andResultsArr:_eventsArray];
}

-(void)showNextEvent {
    [self.detailContainer switchViewController:[_eventsArray objectAtIndex:_eventIndex + 1] andResultsArr:_eventsArray];
}

- (void)setupFavoriteButton {
    self.favoriteButton = [[UiTGlobalFunctions sharedInstance] createFavoriteOrShareButton:@"FAVORITE"];
    [self.favoriteButton setFrame:CGRectMake(40, HEIGHT(self.view) - 103, 320/2 - 40, 40)];
    [self.favoriteButton setTitleColor:TITLECOLOR forState:UIControlStateNormal];
    self.favoriteButton.backgroundColor = [UIColor whiteColor];
    [self.favoriteButton addTarget:self action:@selector(favoriteEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    
    if (context) {
        UiTFavorite *fav = [UiTFavorite favoriteWithEventId:_event.cdbid usingManagedObjectContext:context];
        [self.favoriteButton setSelected:(fav == nil ? NO : YES)];
    }
    
    [self.view addSubview:self.favoriteButton];
}

-(void)viewWillAppear:(BOOL)animated {
    if (self.favoriteButton) {
        NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
        
        if (context) {
            UiTFavorite *fav = [UiTFavorite favoriteWithEventId:_event.cdbid usingManagedObjectContext:context];
            [self.favoriteButton setSelected:(fav == nil ? NO : YES)];
        }
    }
}

- (void)setupShareButton {
    self.shareButton = [[UiTGlobalFunctions sharedInstance] createFavoriteOrShareButton:@"SHARE"];
    [self.shareButton setFrame:CGRectMake(RIGHT(self.favoriteButton), HEIGHT(self.view) - 103, 320/2 - 40, 40)];
    [self.shareButton setTitleColor:TITLECOLOR forState:UIControlStateNormal];
    self.shareButton.backgroundColor = [UIColor whiteColor];
    [self.shareButton addTarget:self action:@selector(shareEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 17.0f, 0.0f, 0.0f)];
    [self.shareButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 17.0f, 0.0f, 0.0f)];
    [self.view addSubview:self.shareButton];
    
}

-(void)favoriteEvent:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    
    NSString *cdbid = _event.cdbid;
    
    if (button.selected) {
        button.selected = NO;
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
                                                                                            action:@"Unfavorite"
                                                                                             label:NSLocalizedString(@"FAVORITE", @"")
                                                                                             value:nil] build]];
        if (context) {
            UiTFavorite *fav = [UiTFavorite favoriteWithEventId:cdbid usingManagedObjectContext:context];
            if (fav != nil) {
                [context deleteObject:fav];
                [context save:nil];
            }
        }
    }
    else {
        button.selected = YES;
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
                                                                                            action:@"Favorite"
                                                                                             label:NSLocalizedString(@"FAVORITE", @"")
                                                                                             value:nil] build]];
        if (context) {
            UiTFavorite *favorite = [UiTFavorite insertInManagedObjectContext:context];
            favorite.eventID = cdbid;
            [context save:nil];
        }
    }
}

-(void)shareEvent:(id)sender {
    NSArray *activityItems;
    
    if (_event.imageURL) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_event.imageURL]];
        activityItems = [NSArray arrayWithObjects:_event.title, [NSString stringWithFormat:@"http://www.uitinvlaanderen.be/agenda/e/app_redirect/%@?utm_campaign=UiTagenda&utm_medium=ios&utm_source=app&utm_content=share", _event.cdbid], @"(Via #UiTagenda)", image, nil];
    }
    else {
        activityItems = [NSArray arrayWithObjects:_event.title, [NSString stringWithFormat:@"http://www.uitinvlaanderen.be/agenda/e/app_redirect/%@?utm_campaign=UiTagenda&utm_medium=ios&utm_source=app&utm_content=share", _event.cdbid], @"(Via #UiTagenda)", nil];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                     applicationActivities:nil];
    
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if([activityType isEqualToString:UIActivityTypeMail]){
            if (completed) {
                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
                                                                                                    action:@"ShareMail"
                                                                                                     label:NSLocalizedString(@"SHARE", @"")
                                                                                                     value:nil] build]];
            }
        }
        if([activityType isEqualToString:UIActivityTypePostToFacebook]){
            if (completed) {
                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
                                                                                                    action:@"ShareFacebook"
                                                                                                     label:NSLocalizedString(@"SHARE", @"")
                                                                                                     value:nil] build]];
            }
        }
        if([activityType isEqualToString:UIActivityTypePostToTwitter]){
            if (completed) {
                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
                                                                                                    action:@"ShareTwitter"
                                                                                                     label:NSLocalizedString(@"SHARE", @"")
                                                                                                     value:nil] build]];
            }
        }
    }];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

-(void)showRoute {
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:_event.address
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc]
                                                   initWithCoordinate:geocodedPlacemark.location.coordinate
                                                   addressDictionary:geocodedPlacemark.addressDictionary];
                         
                         MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                         [mapItem setName:_event.title];
                         
                         NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                         
                         MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                         
                         [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                     }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end