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
@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic) NSInteger yOffset, eventIndex;
@property (strong, nonatomic) UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewKids;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *calendarImageView;
@property (weak, nonatomic) IBOutlet UILabel *calendarLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortDescriptionPlaceLabel;

@property (weak, nonatomic) IBOutlet UiTInfoLabel *organiserInfoLabel;
@property (weak, nonatomic) IBOutlet UiTInfoLabel *priceInfoLabel;
@property (weak, nonatomic) IBOutlet UiTTitleLabel *priceTitleDescriptionLabel;
@property (weak, nonatomic) IBOutlet UiTInfoLabel *priceInfoDescriptionLabel;
@property (weak, nonatomic) IBOutlet UiTInfoLabel *reservationInfoLabel;
@property (weak, nonatomic) IBOutlet UiTTitleLabel *linksTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *shortDescriptionView;
@property (weak, nonatomic) IBOutlet UIView *organiserView;
@property (weak, nonatomic) IBOutlet UIView *contactView;
@property (weak, nonatomic) IBOutlet UIView *reservationView;
@property (weak, nonatomic) IBOutlet UIView *linksView;
@property (weak, nonatomic) IBOutlet UIView *priceView;
@property (weak, nonatomic) IBOutlet UIView *performersView;
@property (weak, nonatomic) IBOutlet UIView *longDescriptionView;
@end

@implementation UiTDetailViewController

- (id)initWithEvent:(UiTEvent *)event andEventsArray:(NSArray *)eventsArray {
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

- (void)viewWillAppear:(BOOL)animated {
    if (self.favoriteButton) {
        NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
        
        if (context) {
            UiTFavorite *fav = [UiTFavorite favoriteWithEventId:_event.cdbid usingManagedObjectContext:context];
            [self.favoriteButton setSelected:(fav == nil ? NO : YES)];
        }
    }
}

- (void)setupScrollView {
    [self.view.layer addSublayer:[[UiTGlobalFunctions sharedInstance] createBorderWithX:0
                                                                                  withY:HEIGHT(self.view) - 104
                                                                              withWidth:WIDTH(self.view)
                                                                             withHeight:1
                                                                              withColor:UIColorFromHex(0xE7E7E7)]];
    
    [self setupFavoriteButton];
    [self setupShareButton];
    [self setupNextAndPrevious];
}

- (void)setupEventView {
    
    // IMAGE
    if (_event.imageURL != nil) {
        NSArray *splitURL = [[NSString stringWithFormat:@"%@", _event.imageURL] componentsSeparatedByString:@"?"];
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%i&height=%i&crop=auto", splitURL[0], (int)(WIDTH(self.view) - 20) * 2, 500]];
        [self.eventImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"no-thumbnail"]];
        self.eventImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.eventImageView.clipsToBounds = YES;
        
        if (_event.ageFrom != nil) {
            if ([_event.ageFrom intValue] <= 11) {
                self.imageViewKids.hidden = NO;
            } else {
                self.imageViewKids.hidden = YES;
            }
        }
    } else {
        self.headerView.hidden = YES;
        self.eventImageView.hidden = YES;
    }
    
    // TITLE
    if (![_event.title isEqualToString:@""]){
        self.eventTitleLabel.text = _event.title;
        self.eventTitleLabel.backgroundColor = [UIColor whiteColor];
        self.eventTitleLabel.font = [[UiTGlobalFunctions sharedInstance] customBoldFontWithSize:20];
        self.eventTitleLabel.textColor = TITLECOLOR;
        self.eventTitleLabel.numberOfLines = 0;
        [self.eventTitleLabel sizeToFit];
        self.yOffset += HEIGHT(self.eventTitleLabel) + paddingTitle;
    } else {
        self.eventTitleLabel.hidden = YES;
    }
    
    if ([_event.categories count] > 0) {
        self.categoryImageView.image = [UIImage imageNamed:@"tagicon"];
        
        self.categoryLabel.text = [_event.categories componentsJoinedByString:@", "];
        self.categoryLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:14];
        self.categoryLabel.textColor = LOCATIONCOLOR;
        self.categoryLabel.numberOfLines = 0;
        [self.categoryLabel sizeToFit];
    
        self.yOffset = BOTTOM(self.categoryLabel) + paddingTitle;
    } else {
        self.categoryImageView.hidden = YES;
    }
    
    if (![_event.calendarSummary isEqualToString:@""]) {
        self.calendarImageView.image = [UIImage imageNamed:@"calendaricon"];
        
        self.calendarLabel.text = _event.calendarSummary;
        self.calendarLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
        self.calendarLabel.textColor = [UIColor blackColor];
        self.calendarLabel.numberOfLines = 0;
        [self.calendarLabel sizeToFit];
    } else {
        self.calendarImageView.hidden = YES;
        self.calendarLabel.hidden = YES;
    }
    
    if (![_event.address isEqualToString:@""]) {
        self.placeImageView.image = [UIImage imageNamed:@"locationicon"];
        
        [self.placeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRoute)]];
        self.placeLabel.text = _event.address;
        self.placeLabel.numberOfLines = 0;
        self.placeLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:13];
        self.placeLabel.textColor = REDCOLOR;
        [self.placeLabel sizeToFit];
        self.yOffset += (HEIGHT(self.placeLabel));
    } else {
        self.placeImageView.hidden = YES;
        self.placeLabel.hidden = YES;
    }
    
    if (![_event.place isEqualToString:@""]) {
        self.shortDescriptionPlaceLabel.text = _event.place;
        self.shortDescriptionPlaceLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
        self.shortDescriptionPlaceLabel.numberOfLines = 0;
        self.shortDescriptionPlaceLabel.textColor = TITLECOLOR;
        [self.shortDescriptionPlaceLabel sizeToFit];
    } else {
        self.shortDescriptionPlaceLabel.hidden = YES;
    }
    
    if (_event.shortDescription != (id)[NSNull null] && ![_event.shortDescription isEqualToString:@"NB"]){
        self.shortDescriptionLabel.text = _event.shortDescription;
        self.shortDescriptionLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
        self.shortDescriptionLabel.textColor = TITLECOLOR;
        self.shortDescriptionLabel.numberOfLines = 0;
        [self.shortDescriptionLabel sizeToFit];
    } else {
        self.shortDescriptionLabel.hidden = YES;
        if (_event.place.length <= 0) {
            self.shortDescriptionView.hidden = YES;
        }
    }
    
    if (![_event.organiser isEqualToString:@""]) {
        self.organiserInfoLabel.text = _event.organiser;
    } else {
        self.organiserView.hidden = YES;
    }
    
    if ([_event.contactInfo count] > 0) {
        CGFloat yOffsetContact = 0;
        for (NSString *contactItem in _event.contactInfo) {
            for (NSString *contactItemInfo in [_event.contactInfo valueForKey:contactItem]) {
                UiTLinkLabel *contactLabel;
                if ([contactItem isEqualToString:@"phone"]) {
                    contactLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetContact, WIDTH(self.contactView) - widthPadding, 400) andText:[self createPhoneNumber:contactItemInfo]];
                } else {
                    contactLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetContact, WIDTH(self.contactView) - widthPadding, 400) andText:contactItemInfo];
                }
                
                [self.contactView addSubview:contactLabel];
            }
        }
    } else {
        self.contactView.hidden = YES;
    }
    
    if ([_event.contactReservationInfo count] > 0) {
        self.reservationView.backgroundColor = [UIColor whiteColor];
        
        UiTTitleLabel *reservationTitle   = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(self.reservationView) - widthPadding, 400)
                                                                        andTitle:NSLocalizedString(@"RESERVATION", @"")];
        [self.reservationView addSubview:reservationTitle];
        
        int yOffsetReservationContact = BOTTOM(reservationTitle) + paddingTitle;
        
        for (NSString *contactItem in _event.contactReservationInfo) {
            for (NSString *contactItemInfo in [_event.contactReservationInfo valueForKey:contactItem]) {
                UiTLinkLabel *contactLabel;
                
                if ([contactItem isEqualToString:@"phone"]) {
                    contactLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetReservationContact, WIDTH(self.reservationView) - widthPadding, 400) andText:[self createPhoneNumber:contactItemInfo]];
                }
                else {
                    contactLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetReservationContact, WIDTH(self.reservationView) - widthPadding, 400) andText:contactItemInfo];
                }
                
                [self.reservationView addSubview:contactLabel];
                yOffsetReservationContact += (HEIGHT(contactLabel) + 10);
            }
        }
    } else {
        self.reservationView.hidden = YES;
    }
    
    if (![_event.price isEqualToString:@""]) {
        
        if ([_event.price isEqualToString:@"0"]) {
            self.priceInfoLabel.text = NSLocalizedString(@"FREE", @"");
        } else {
            self.priceInfoLabel.text = [NSString stringWithFormat:@"€%@", _event.price];
        }
        
        if (![_event.priceDescription isEqualToString:@""]) {
            self.priceInfoDescriptionLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"EXTRA INFO", @""), _event.priceDescription];
        }
    } else {
        self.priceView.hidden = YES;
    }
    
    if ([_event.mediaInfo count] > 0) {

        int yOffsetMedia = BOTTOM(self.linksTitleLabel) + paddingTitle;
        
        for (NSString *mediaInfo in _event.mediaInfo) {
            UiTLinkLabel *mediaLabel = [[UiTLinkLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetMedia, WIDTH(self.linksView) - widthPadding, 400) andText:mediaInfo];
            [self.linksView addSubview:mediaLabel];
            yOffsetMedia += (HEIGHT(mediaLabel) + 10);
        }
    } else {
        self.linksView.hidden = YES;
    }
    
    if ([_event.performers count] > 0) {
        UiTTitleLabel *performersTitle   = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(self.performersView) - widthPadding, 400) andTitle:NSLocalizedString(@"PERFORMERS", @"")];
        [self.performersView addSubview:performersTitle];
        
        int yOffsetPerformers = BOTTOM(performersTitle) + paddingTitle;
        
        for (NSArray *performer in _event.performers) {
            
            UiTInfoLabel *performerLabel;
            if ([performer valueForKeyPath:@"role"] != [NSNull null]) {
                performerLabel = [[UiTInfoLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetPerformers, WIDTH(self.performersView) - widthPadding, 400)
                                                             andText:[NSString stringWithFormat:@"%@ \nRol: %@\n", [performer valueForKeyPath:@"label.value"], [performer valueForKeyPath:@"role"]]];
            } else {
                performerLabel = [[UiTInfoLabel alloc] initWithFrame:CGRectMake(insetLeft, yOffsetPerformers, WIDTH(self.performersView) - widthPadding, 400)
                                                             andText:[performer valueForKeyPath:@"label.value"]];
            }
            
            [self.performersView addSubview:performerLabel];
        }
    } else {
        self.performersView.hidden = YES;
    }
    
    if (![_event.longDescription isEqualToString:@""]) {
        UiTTitleLabel *longDescriptionTitle = [[UiTTitleLabel alloc] initWithFrame:CGRectMake(insetLeft, 20, WIDTH(self.view) - widthPadding, 400) andTitle:NSLocalizedString(@"LONG DESCRIPTION", @"")];
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, BOTTOM(longDescriptionTitle) + 5, 290, 20)];
        _webView.delegate = self;
        
        NSString *stringWithFont = [NSString stringWithFormat:@"<style type='text/css'>* { font-family: \"PT Sans Narrow\"; } </style>%@", _event.longDescription];
        [_webView loadHTMLString:stringWithFont baseURL:nil];
    } else {
        self.longDescriptionView.hidden = YES;
    }
}

- (NSString *)createPhoneNumber:(NSString *)contactItem {
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

- (void)setupNextAndPrevious {
//    _previousButton = [[UIButton alloc] initWithFrame:CGRectMake(0, HEIGHT(self.view) - 103, 41, 40)];
    _previousButton.backgroundColor = REDCOLOR;
    [_previousButton addTarget:self action:@selector(showPreviousEvent) forControlEvents:UIControlEventTouchUpInside];
    [_previousButton setImage:[UIImage imageNamed:@"backicon"] forState:UIControlStateNormal];
//    _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(RIGHT(self.shareButton) - 1, HEIGHT(self.view) - 103, 41, 40)];
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

- (void)showNextEvent {
    [self.detailContainer switchViewController:[_eventsArray objectAtIndex:_eventIndex + 1] andResultsArr:_eventsArray];
}

- (void)setupFavoriteButton {
    self.favoriteButton = [[UiTGlobalFunctions sharedInstance] createFavoriteOrShareButton:@"FAVORITE"];
//    [self.favoriteButton setFrame:CGRectMake(40, HEIGHT(self.view) - 103, 320/2 - 40, 40)];
    [self.favoriteButton setTitleColor:TITLECOLOR forState:UIControlStateNormal];
    self.favoriteButton.backgroundColor = [UIColor whiteColor];
    [self.favoriteButton addTarget:self action:@selector(favoriteEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.favoriteButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 0.0f)];
    [self.favoriteButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 8.0f, 0.0f, 0.0f)];
    
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    
    if (context) {
        UiTFavorite *fav = [UiTFavorite favoriteWithEventId:_event.cdbid usingManagedObjectContext:context];
        [self.favoriteButton setSelected:(fav == nil ? NO : YES)];
    }
    
    [self.view addSubview:self.favoriteButton];
}

- (void)setupShareButton {
//    self.shareButton = [[UiTGlobalFunctions sharedInstance] createFavoriteOrShareButton:@"SHARE"];
//    [self.shareButton setFrame:CGRectMake(RIGHT(self.favoriteButton), HEIGHT(self.view) - 103, 320/2 - 40, 40)];
    [self.shareButton setTitleColor:TITLECOLOR forState:UIControlStateNormal];
    self.shareButton.backgroundColor = [UIColor whiteColor];
    [self.shareButton addTarget:self action:@selector(shareEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 0.0f)];
    [self.shareButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 8.0f, 0.0f, 0.0f)];
//    [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 17.0f, 0.0f, 0.0f)];
//    [self.shareButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 17.0f, 0.0f, 0.0f)];
    [self.view addSubview:self.shareButton];
    
}

- (void)favoriteEvent:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    
    NSString *cdbid = _event.cdbid;
    
    if (button.selected) {
        button.selected = NO;
//        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
//                                                                                            action:@"Unfavorite"
//                                                                                             label:NSLocalizedString(@"FAVORITE", @"")
//                                                                                             value:nil] build]];
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
//        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
//                                                                                            action:@"Favorite"
//                                                                                             label:NSLocalizedString(@"FAVORITE", @"")
//                                                                                             value:nil] build]];
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
//                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
//                                                                                                    action:@"ShareMail"
//                                                                                                     label:NSLocalizedString(@"SHARE", @"")
//                                                                                                     value:nil] build]];
            }
        }
        if([activityType isEqualToString:UIActivityTypePostToFacebook]){
            if (completed) {
//                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
//                                                                                                    action:@"ShareFacebook"
//                                                                                                     label:NSLocalizedString(@"SHARE", @"")
//                                                                                                     value:nil] build]];
            }
        }
        if([activityType isEqualToString:UIActivityTypePostToTwitter]){
            if (completed) {
//                [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"DetailCellFavorite"
//                                                                                                    action:@"ShareTwitter"
//                                                                                                     label:NSLocalizedString(@"SHARE", @"")
//                                                                                                     value:nil] build]];
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