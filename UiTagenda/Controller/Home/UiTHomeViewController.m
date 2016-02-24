//
//  UiTHomeViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTHomeViewController.h"
#import "UiTAPIClient.h"
#import "UiTDetailViewController.h"
#import "UiTDetailCell.h"
#import "UiTEvent.h"
#import "UitagendaDataModel.h"
#import "UiTFavorite.h"
#import "UiTProblemView.h"
#import "NSMutableArray+UiTMap.h"

#import <SVPullToRefresh/SVPullToRefresh.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <TSMessages/TSMessage.h>
#import <QuartzCore/QuartzCore.h>

@interface UiTHomeViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIAlertViewDelegate, TSMessageViewProtocol>

@property (weak, nonatomic) IBOutlet UITableView *eventTableView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSMutableArray *resultsArray;
@property (nonatomic, assign) NSInteger currentEvents, totalEvents;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIImageView *noDataImageView;
@property (strong, nonatomic) UiTProblemView *problemView;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (nonatomic) BOOL noLocationMessageShowed;

@property (nonatomic, assign) BOOL locationUpdated;

@end

@implementation UiTHomeViewController

static BOOL haveAlreadyReceivedCoordinates;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupTableView];
    
    [[GoogleAnalyticsTracker sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"HOME", @"")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.eventTableView reloadData];
}

- (void)setupView {
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.currentEvents = 0;
    self.totalEvents = 0;
    self.resultsArray = [[NSMutableArray alloc] init];
    self.title = NSLocalizedString(@"HOME", @"");
    
    [self searchLocation];
}

- (void)setupHud {
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.dimBackground = YES;
    self.hud.labelText = NSLocalizedString(@"LOADING EVENTS", @"");
    self.hud.detailsLabelText = NSLocalizedString(@"LOADING MESSAGE", @"");
    self.hud.labelFont = [UIFont customBoldFontWithSize:18];
    self.hud.detailsLabelFont = [UIFont customRegularFontWithSize:16];
    [self.hud show:YES];
    [self.navigationController.view addSubview:self.hud];
}

- (void)resetView {
    self.currentEvents = 0;
    self.totalEvents = 0;
    self.eventTableView.tableFooterView = nil;
    [self searchLocation];
}

- (void)setupTableView {
    self.eventTableView.backgroundColor = BACKGROUNDCOLOR;
    [self.eventTableView registerClass:[UiTDetailCell class] forCellReuseIdentifier:NSStringFromClass([UiTDetailCell class])];

    __weak UiTHomeViewController *weakSelf = self;
    
    [self.eventTableView addPullToRefreshWithActionHandler:^{
        [weakSelf resetView];
    }];
    
    [self.eventTableView addInfiniteScrollingWithActionHandler:^{
        if (haveAlreadyReceivedCoordinates || !_locationUpdated) {
            [weakSelf fetchEvents];
        }
    }];
    
    [self.eventTableView.pullToRefreshView setTitle:NSLocalizedString(@"PULL TO REFRESH", @"") forState:SVPullToRefreshStateStopped];
    [self.eventTableView.pullToRefreshView setTitle:NSLocalizedString(@"RELEASE TO REFRESH", @"") forState:SVPullToRefreshStateTriggered];
    [self.eventTableView.pullToRefreshView setTitle:NSLocalizedString(@"LOADING", @"") forState:SVPullToRefreshStateLoading];
    
    self.problemView = [[UiTProblemView alloc] initWithFrame:CGRectMake(CENTER_IN_PARENT_X(self.view, 250), CENTER_IN_PARENT_Y(self.view, 250), 250, 250)];
    self.problemView.hidden = YES;
    [self.eventTableView addSubview:self.problemView];
}

- (void)searchLocation {
    [self setupHud];
    haveAlreadyReceivedCoordinates = NO;
    [self.locationManager startUpdatingLocation];
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.delegate = self;
        if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    return _locationManager;
}

- (void)hideProblemView:(BOOL)hide withRemark:(NSString *)remark {
    _problemView.hidden = hide;
    _problemView.problemLabel.text = remark;
}

#pragma mark - API

- (void)fetchEvents {
    _problemView.hidden = YES;
    NSMutableSet *fqSet = [[NSMutableSet alloc] init];
    
    [fqSet addObject:@"-category_id:0.3.1.0.0"];
    [fqSet addObject:@"type:event"];
    [fqSet addObject:@"language:nl"];
    
    NSMutableDictionary *parameters = [@{
                                        @"q": @"*:*",
                                        @"rows" : [NSString stringWithFormat:@"%i", amountOfRows],
                                        @"group" : @"event",
                                        @"fq": fqSet,
                                        @"datetype": @"today",
                                        @"start" : [NSString stringWithFormat:@"%li", (long)self.currentEvents]
                                        } mutableCopy];

    if (_locationUpdated) {
        [parameters setObject:@"physical_gis" forKey:@"sfield"];
        [parameters setObject:[NSString stringWithFormat:@"%i", (int)RADIUS] forKey:@"d"];
        [parameters setObject:@"geodist() asc" forKey:@"sort"];
        [parameters setObject:[NSString stringWithFormat:@"%f,%f",_location.coordinate.latitude, _location.coordinate.longitude] forKey:@"pt"];
    } else {
        [parameters setObject:@"startdate asc" forKey:@"sort"];
    }
    
    [[UiTAPIClient sharedClient] getPath:@"searchv2/search"
                           getParameters:parameters
                              completion:^(NSArray *results, NSError *error) {
                                  
                                  if (_currentEvents == 0) {
                                      _resultsArray = [NSMutableArray array];
                                  }
                                  
                                  if (!_locationUpdated && !_noLocationMessageShowed) {
                                      [self showNoLocationMessage];
                                  }
                                  
                                  if (results) {
                                      [self handleApiResults:results];
                                  } else {
                                      if (![_resultsArray count] > 0) {
                                          [self hideProblemView:NO withRemark:NSLocalizedString(@"SOMETHING WENT WRONG", @"")];
                                      }
                                      self.eventTableView.showsInfiniteScrolling = NO;
                                  }
                                  
                                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                  [self.eventTableView.pullToRefreshView stopAnimating];
                                  [self.eventTableView.infiniteScrollingView stopAnimating];
                                  [self.eventTableView reloadData];
                                  self.hud.hidden = YES;
                              }];
}

- (void)showNoLocationMessage {
    [TSMessage showNotificationInViewController:self
                                          title:@"Locatie bepalen mislukt."
                                       subtitle:@"Staan de locatievoorzieningen aan? Schakel deze in om locatie-gebaseerde events te bekijken."
                                          image:nil
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:^{
                                           if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                                               [self openSettings];
                                           }
                                       }
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
    _noLocationMessageShowed = YES;
}

- (void)handleApiResults:(NSArray *)results {
    NSMutableArray *resultsArray = [[results valueForKey:@"rootObject"] mutableCopy];
    
    self.totalEvents = [[[resultsArray firstObject] valueForKey:@"Long"] intValue];
    
    [resultsArray removeObjectAtIndex:0];
    
    [_resultsArray addObjectsFromArray:[resultsArray UiT_map:^UiTEvent*(NSDictionary *eventDictionary) {
        return [[UiTEvent alloc] initWithDictionary:eventDictionary];
    }]];
    
    self.currentEvents += amountOfRows;
    
    if (self.currentEvents >= self.totalEvents) {
        self.eventTableView.showsInfiniteScrolling = NO;
        if (self.totalEvents > amountOfRows) {
            UIView *view = [[UIView alloc ]initWithFrame:CGRectMake(10, -5, WIDTH(self.eventTableView) - 40, 30)];
            UILabel *endResults = [[UILabel alloc] initWithFrame:view.frame];
            endResults.textAlignment = NSTextAlignmentCenter;
            endResults.font = [UIFont customRegularFontWithSize:16];
            endResults.text = @"Einde van de resultaten!";
            endResults.textColor = [UIColor lightGrayColor];
            [view addSubview:endResults];
            self.eventTableView.tableFooterView = view;
        }
    } else {
        self.eventTableView.showsInfiniteScrolling = YES;
    }
    
    if (self.totalEvents == 0) {
        self.eventTableView.tableFooterView = nil;
        [self hideProblemView:NO withRemark:NSLocalizedString(@"NO RESULTS", @"")];
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(!haveAlreadyReceivedCoordinates) {
        self.title = NSLocalizedString(@"HOME", @"");
        _location = [locations lastObject];
        _locationUpdated = YES;
        [self fetchEvents];
    }
    [self.locationManager stopUpdatingLocation];
    
    haveAlreadyReceivedCoordinates = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    self.title = NSLocalizedString(@"HOME_WITHOUT_LOCATION", @"");
    _locationUpdated = NO;
    [self fetchEvents];
}

- (void)openSettings {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _problemView.frame = CGRectMake(CENTER_IN_PARENT_X(self.view, 250), CENTER_IN_PARENT_Y(self.view, 250), 250, 250);
}

#pragma mark - TableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row < self.resultsArray.count ? 112 : 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.eventTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    UiTDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"homeDetailVC"];
    UiTDetailContainerViewController *contVc = [[UiTDetailContainerViewController alloc] initWithRootViewController:vc];
    vc.event = self.resultsArray[indexPath.row];
    vc.eventsArray = self.resultsArray;
    [self.navigationController pushViewController:contVc animated:YES];
}

#pragma mark - TableView DataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UiTDetailCell *cell = (UiTDetailCell *)[self.eventTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UiTDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([_resultsArray count] > 0) {
        
        UiTEvent *event = self.resultsArray[indexPath.row];
        cell.event = event;
        
        if (_locationUpdated) {
            cell.distanceLabel.text = [event getDistanceToEventFromLocation:_location];
        } else {
            cell.distanceLabel.text = @"";
        }
        
        [cell.distanceLabel sizeToFit];
        
        cell.cityLabel.text = [NSString stringWithFormat:@"%@", event.city];
        
        cell.favoriteButton.tag = indexPath.row;
        [cell.favoriteButton addTarget:self action:@selector(favoriteEventAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (IBAction)favoriteEventAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    
    NSString *cdbid = ((UiTEvent *)[self.resultsArray objectAtIndex:button.tag]).cdbid;
    
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
    } else {
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

@end