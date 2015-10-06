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
@property (nonatomic) NSInteger eventIndex;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

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
@property (weak, nonatomic) IBOutlet UiTLinkLabel *reservationInfoLabel;
@property (weak, nonatomic) IBOutlet UiTTitleLabel *linksTitleLabel;
@property (weak, nonatomic) IBOutlet UiTLinkLabel *linksLabel;
@property (weak, nonatomic) IBOutlet UiTLinkLabel *contactLabel;
@property (weak, nonatomic) IBOutlet UiTInfoLabel *performerLabel;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *shortDescriptionView;
@property (weak, nonatomic) IBOutlet UIView *organiserView;
@property (weak, nonatomic) IBOutlet UIView *contactView;
@property (weak, nonatomic) IBOutlet UIView *reservationView;
@property (weak, nonatomic) IBOutlet UIView *linksView;
@property (weak, nonatomic) IBOutlet UIView *priceView;
@property (weak, nonatomic) IBOutlet UIView *performersView;
@property (weak, nonatomic) IBOutlet UIView *longDescriptionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webviewHeightConstraint;
@end

@implementation UiTDetailViewController

- (void)viewDidLoad {
    NSLog(@"%@", self.event);
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
        [self.eventTitleLabel sizeToFit];
    } else {
        self.eventTitleLabel.hidden = YES;
    }
    
    if ([_event.categories count] > 0) {
        self.categoryImageView.image = [UIImage imageNamed:@"tagicon"];
        self.categoryLabel.text = [_event.categories componentsJoinedByString:@", "];
        [self.categoryLabel sizeToFit];
    } else {
        self.categoryImageView.hidden = YES;
    }
    
    if (![_event.calendarSummary isEqualToString:@""]) {
        self.calendarLabel.text = _event.calendarSummary;
        [self.calendarLabel sizeToFit];
    } else {
        self.calendarImageView.hidden = YES;
        self.calendarLabel.hidden = YES;
    }
    
    if (![_event.address isEqualToString:@""]) {
        [self.placeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRoute)]];
        self.placeLabel.text = _event.address;
        [self.placeLabel sizeToFit];
    } else {
        self.placeImageView.hidden = YES;
        self.placeLabel.hidden = YES;
    }
    
    if (![_event.place isEqualToString:@""]) {
        self.shortDescriptionPlaceLabel.text = _event.place;
        [self.shortDescriptionPlaceLabel sizeToFit];
    } else {
        self.shortDescriptionPlaceLabel.hidden = YES;
    }
    
    if (_event.shortDescription != (id)[NSNull null] && ![_event.shortDescription isEqualToString:@"NB"]){
        self.shortDescriptionLabel.text = _event.shortDescription;
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
        NSString *contactString = @"";
        for (NSString *contactItem in _event.contactInfo) {
            for (NSString *contactItemInfo in [_event.contactInfo valueForKey:contactItem]) {
                
                if ([contactItem isEqualToString:@"phone"]) {
                    contactString = [contactString stringByAppendingString:[NSString stringWithFormat:@"%@\n", [self createPhoneNumber:contactItemInfo]]];
                } else {
                    contactString = [contactString stringByAppendingString:[NSString stringWithFormat:@"%@\n", contactItemInfo]];
                }
            }
        }
        self.contactLabel.text = contactString;
    } else {
        self.contactView.hidden = YES;
    }
    
    if ([_event.contactReservationInfo count] > 0) {
        self.reservationView.backgroundColor = [UIColor whiteColor];
        NSString *reservationString = @"";
        
        for (NSString *contactItem in _event.contactReservationInfo) {
            for (NSString *contactItemInfo in [_event.contactReservationInfo valueForKey:contactItem]) {
                if ([contactItem isEqualToString:@"phone"]) {
                    reservationString = [reservationString stringByAppendingString:[NSString stringWithFormat:@"%@\n", [self createPhoneNumber:contactItemInfo]]];
                } else {
                    reservationString = [reservationString stringByAppendingString:[NSString stringWithFormat:@"%@\n", contactItemInfo]];
                }
            }
        }
        self.reservationInfoLabel.text = reservationString;
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
        NSString *mediaString = @"";
        for (NSString *mediaInfo in _event.mediaInfo) {
            mediaString = [mediaString stringByAppendingString:[NSString stringWithFormat:@"%@\n", mediaInfo]];
        }
        self.linksLabel.text = mediaString;
    } else {
        self.linksView.hidden = YES;
    }
    
    if ([_event.performers count] > 0) {
        NSString *performersString = @"";
        
        for (NSArray *performer in _event.performers) {
            if ([performer valueForKeyPath:@"role"] != [NSNull null]) {
                NSString *textString = [NSString stringWithFormat:@"%@ \nRol: %@\n", [performer valueForKeyPath:@"label.value"], [performer valueForKeyPath:@"role"]];
                performersString = [performersString stringByAppendingString:[NSString stringWithFormat:@"%@\n", textString]];
            } else {
                performersString = [performersString stringByAppendingString:[NSString stringWithFormat:@"%@\n", [performer valueForKeyPath:@"label.value"]]];
            }
        }
        self.performerLabel.text = performersString;
    } else {
        self.performersView.hidden = YES;
    }
    
    if (![_event.longDescription isEqualToString:@""]) {
        NSString *stringWithFont = [NSString stringWithFormat:@"<style type='text/css'>* { font-family: \"PT Sans Narrow\"; } </style>%@", _event.longDescription];
        [self.webView loadHTMLString:stringWithFont baseURL:nil];
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

- (void)setupNextAndPrevious {
    [_previousButton addTarget:self action:@selector(showPreviousEvent) forControlEvents:UIControlEventTouchUpInside];
    [_nextButton addTarget:self action:@selector(showNextEvent) forControlEvents:UIControlEventTouchUpInside];
    
    if (_eventIndex == 0) {
        _previousButton.enabled = FALSE;
    } else {
        _previousButton.enabled = TRUE;
    }
    
    if (_eventIndex == [_eventsArray count] - 1) {
        _nextButton.enabled  = FALSE;
    } else {
        _nextButton.enabled = TRUE;
    }
}

- (void)setupFavoriteButton {
    [self.favoriteButton addTarget:self action:@selector(favoriteEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.favoriteButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 0.0f)];
    [self.favoriteButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 8.0f, 0.0f, 0.0f)];
    
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    
    if (context) {
        UiTFavorite *fav = [UiTFavorite favoriteWithEventId:_event.cdbid usingManagedObjectContext:context];
        [self.favoriteButton setSelected:(fav == nil ? NO : YES)];
    }
}

- (void)setupShareButton {
    [self.shareButton addTarget:self action:@selector(shareEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 0.0f)];
    [self.shareButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 8.0f, 0.0f, 0.0f)];
}

- (void)showRoute {
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

#pragma mark - IBActions

- (void)showPreviousEvent {
    [self.detailContainer switchViewController:[_eventsArray objectAtIndex:_eventIndex - 1] andResultsArr:_eventsArray];
}

- (void)showNextEvent {
    [self.detailContainer switchViewController:[_eventsArray objectAtIndex:_eventIndex + 1] andResultsArr:_eventsArray];
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
    } else {
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

- (void)shareEvent:(id)sender {
    NSArray *activityItems;
    
    if (_event.imageURL) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_event.imageURL]];
        activityItems = [NSArray arrayWithObjects:_event.title, [NSString stringWithFormat:@"http://www.uitinvlaanderen.be/agenda/e/app_redirect/%@?utm_campaign=UiTagenda&utm_medium=ios&utm_source=app&utm_content=share", _event.cdbid], @"(Via #UiTagenda)", image, nil];
    } else {
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
        
        if ([activityType isEqualToString:UIActivityTypePostToFacebook]){
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

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    self.webviewHeightConstraint.constant = fittingSize.height;
    [self.longDescriptionView layoutSubviews];
}

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if (inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

@end