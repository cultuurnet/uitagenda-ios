//
//  UiTSearchResultsViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTSearchResultsViewController.h"
#import "SVPullToRefresh/SVPullToRefresh.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "UiTAPIClient.h"
#import "UiTEvent.h"
#import "UitagendaDataModel.h"
#import "UiTFavorite.h"
#import "UiTDetailViewController.h"
#import "UiTDetailCell.h"
#import "UiTSearchQuery.h"
#import "UiTNavViewController.h"
#import "UiTFavoritesViewController.h"
#import "UiTProblemView.h"
#import "NSMutableArray+UiTMap.h"

@interface UiTSearchResultsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) NSMutableArray *resultsArray;
@property (nonatomic) NSInteger currentEvents, totalEvents;
@property (strong, nonatomic) NSMutableDictionary *queryDictionary;
@property (strong, nonatomic) NSString *searchTerm, *radius, *when;
@property (strong, nonatomic) NSMutableDictionary *where, *what, *extraCriteria;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) BOOL currentLocation, alreadySaved;
@property (strong, nonatomic) UIImageView *noDataImageView;
@property (strong, nonatomic) UiTProblemView *problemView;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation UiTSearchResultsViewController

static BOOL haveAlreadyReceivedCoordinates;

- (void)setSearchTerm:(NSString *)searchTerm
  withCurrentLocation:(BOOL)currentLocation
           withRadius:(NSString *)radius
             withWhen:(NSString *)when
            withWhere:(NSMutableDictionary *)where
             withWhat:(NSMutableDictionary *)what
    withExtraCriteria:(NSMutableDictionary *)extraCriteria
       withSavedQuery:(BOOL)alreadySaved {
    _searchTerm = searchTerm;
    _currentLocation = currentLocation;
    _radius = radius;
    _when = when;
    _where = where ? where : [[NSMutableDictionary alloc] init];
    _what = what ? what : [[NSMutableDictionary alloc] init];
    _extraCriteria = extraCriteria;
    _alreadySaved = alreadySaved;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupTableView];
    [self createQueryDictonary];
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"SEARCHRESULTS", @"")];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

#pragma mark - Setup

- (void)setupView {
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.currentEvents = 0;
    self.totalEvents = 0;
    self.resultsArray = [[NSMutableArray alloc] init];
    self.title = NSLocalizedString(@"SEARCHRESULTS", @"");
    self.navigationItem.rightBarButtonItem = [self showRightBarButton:@"favorite"];
    self.navigationItem.leftBarButtonItem = nil;

    if (_currentLocation) {
        [self searchLocation];
    } else {
        [self setupHud];
        [self fetchEvents];
    }
}

- (void)setupHud {
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.dimBackground = YES;
    self.hud.labelText = NSLocalizedString(@"LOADING EVENTS", @"");
    self.hud.detailsLabelText = NSLocalizedString(@"LOADING MESSAGE", @"");
    self.hud.labelFont = [[UiTGlobalFunctions sharedInstance] customBoldFontWithSize:18];
    self.hud.detailsLabelFont = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
    [self.hud show:YES];
    [self.navigationController.view addSubview:self.hud];
}

- (UIBarButtonItem *)showRightBarButton:(NSString *)imageName {
    UIImage *barBtnImage = [UIImage imageNamed:imageName];
    UIImage *barBtnImageActive = [UIImage imageNamed:[NSString stringWithFormat:@"%@Highlighted", imageName]];
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [barButton setBackgroundImage:barBtnImage forState:UIControlStateNormal];
    [barButton setBackgroundImage:barBtnImageActive forState:UIControlStateHighlighted];
    
    [barButton setFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
    
    [barButton addTarget:self action:@selector(showFavoritesModalAction) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:barButton];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    return item;
}

- (void)setupTableView {
    self.tableView.backgroundColor = BACKGROUNDCOLOR;
    [self.tableView registerClass:[UiTDetailCell class] forCellReuseIdentifier:NSStringFromClass([UiTDetailCell class])];

    __weak UiTSearchResultsViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf resetView];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf fetchEvents];
    }];
    
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"PULL TO REFRESH", @"") forState:SVPullToRefreshStateStopped];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"RELEASE TO REFRESH", @"") forState:SVPullToRefreshStateTriggered];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"LOADING", @"") forState:SVPullToRefreshStateLoading];
    
    if (_alreadySaved) {
        self.saveButton.hidden = YES;
        self.closeButton.hidden = YES;
        self.tableView.tableHeaderView = nil;
    }
    
    _problemView = [[UiTProblemView alloc] initWithFrame:CGRectMake(CENTER_IN_PARENT_X(self.tableView, 250), CENTER_IN_PARENT_Y(self.tableView, 250), 250, 250)];
    _problemView.hidden = YES;
    [self.tableView addSubview:_problemView];
}

- (NSString *)setupSaveQueryTitle {
    NSMutableArray *titleItems = [[NSMutableArray alloc] init];
    
    if (![_searchTerm isEqualToString:@""]) {
        [titleItems addObject:_searchTerm];
    }
    
    if ([_where count] > 0) {
        [titleItems addObject:[[[_where allValues] valueForKey:@"title"] firstObject]];
    }
    
    if (![_radius isEqualToString:@""]) {
        [titleItems addObject:[NSString stringWithFormat:@"%@ km", _radius]];
    }
    
    if (![_when isEqualToString:@""]) {
        [titleItems addObject:NSLocalizedString([_when uppercaseString], @"")];
    }
    
    if ([_what count] > 0) {
        for (NSString *eventType in [[_what allValues] valueForKey:@"title"]) {
            [titleItems addObject:eventType];
        }
    }
    
    if ([_extraCriteria count] > 0) {
        for (NSString *extraCriteria in [_extraCriteria allValues]) {
            [titleItems addObject:extraCriteria];
        }
    }
    
    NSString *title = [titleItems componentsJoinedByString:@" - "];
    
    return title;
}

#pragma mark - API

- (void)fetchEvents {
    _problemView.hidden = YES;
    NSMutableSet *fqSet = [self buildFQSet];
    
    NSDictionary *parameters = @{@"q": [_searchTerm isEqualToString:@""] ? @"*:*" : [_searchTerm stringByReplacingOccurrencesOfString:@" " withString:@" AND "],
                                 @"group" : @"event",
                                 @"sort" : @"startdate asc",
                                 @"fq" : fqSet,
                                 @"rows" : [NSString stringWithFormat:@"%i", amountOfRows],
                                 @"start" : [NSString stringWithFormat:@"%li", (long)self.currentEvents]};
    
    NSMutableDictionary *finalParameters = [parameters mutableCopy];
    
    if (_currentLocation) {
        [finalParameters setObject:@"physical_gis" forKey:@"sfield"];
        [finalParameters setObject:@"geodist() asc" forKey:@"sort"];
        if (![_radius isEqualToString:@""]) {
            [finalParameters setObject:_radius forKey:@"d"];
        }
        [finalParameters setObject:[NSString stringWithFormat:@"%f,%f",_location.coordinate.latitude, _location.coordinate.longitude]
                            forKey:@"pt"];
        
    } else if ([_where count] != 0) {
        if (![_radius isEqualToString:@""]) {
            [finalParameters setValue:[NSString stringWithFormat:@"%@!%@", [[[[_where allValues] firstObject] valueForKey:@"title"] substringToIndex:4], _radius] forKey:@"zipcode"];
        } else {
            [finalParameters setValue:[NSString stringWithFormat:@"%@", [[[[_where allValues] firstObject] valueForKey:@"title"] substringToIndex:4]] forKey:@"zipcode"];
        }
    } else {
        
    }
    
    if (![_when isEqualToString:@""]) {
        [finalParameters setValue:_when forKey:@"datetype"];
    }
    
    [[UiTAPIClient sharedClient] getPath:@"searchv2/search"
                           getParameters:finalParameters
                              completion:^(NSArray *results, NSError *error) {
                                  if (results) {
                                      NSMutableArray *resultsArray = [[results valueForKey:@"rootObject"] mutableCopy];
                                      
                                      self.totalEvents = [[[resultsArray firstObject] valueForKey:@"Long"] intValue];
                                      
                                      [resultsArray removeObjectAtIndex:0];
                                      
                                      [self.resultsArray addObjectsFromArray:[resultsArray
                                                                          UiT_map:^UiTEvent*(NSDictionary *eventDictionary) {
                                          return [[UiTEvent alloc] initWithDictionary:eventDictionary];
                                      }]];
                                      
                                      self.currentEvents += amountOfRows;
                                      
                                      if (self.currentEvents >= self.totalEvents) {
                                          self.tableView.showsInfiniteScrolling = NO;
                                          if (self.totalEvents > amountOfRows) {
                                              UIView *view = [[UIView alloc ]initWithFrame:CGRectMake(10, -5, WIDTH(self.tableView) - 40, 30)];
                                              UILabel *endResults = [[UILabel alloc] initWithFrame:view.frame];
                                              endResults.textAlignment = NSTextAlignmentCenter;
                                              endResults.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
                                              endResults.text = @"Einde van de resultaten!";
                                              endResults.textColor = [UIColor lightGrayColor];
                                              [view addSubview:endResults];
                                              self.tableView.tableFooterView = view;
                                          }
                                      } else {
                                          self.tableView.showsInfiniteScrolling = YES;
                                      }
                                      
                                      if (self.totalEvents == 0) {
                                          self.tableView.tableFooterView = nil;
                                          [self hideProblemView:NO withRemark:NSLocalizedString(@"NO RESULTS", @"")];
                                      }
                                  } else {
                                      [self hideProblemView:NO withRemark:NSLocalizedString(@"SOMETHING WENT WRONG", @"")];
                                      self.tableView.showsInfiniteScrolling = NO;
                                  }
                                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                  [self.tableView.pullToRefreshView stopAnimating];
                                  [self.tableView.infiniteScrollingView stopAnimating];
                                  [self.tableView reloadData];
                                  [self.tableView.pullToRefreshView setHidden:NO];
                                  self.hud.hidden = YES;
                              }];
}

#pragma mark - IBActions

- (IBAction)closeAction {
    [UIView beginAnimations:nil context:NULL];
    [self.tableView setTableHeaderView:nil];
    [UIView commitAnimations];
}

- (IBAction)saveSearchQueryAction {
   [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SAVE SEARCHQUERY?", @"")
                              message:nil
                             delegate:self
                    cancelButtonTitle:NSLocalizedString(@"CANCEL", @"")
                    otherButtonTitles:NSLocalizedString(@"SAVE", @""), nil] show];
}

#pragma mark - Custom Methods

- (void)createQueryDictonary {
    _queryDictionary = [[NSMutableDictionary alloc] init];
    [_queryDictionary setObject:_searchTerm forKey:@"searchTerm"];
    [_queryDictionary setObject:_radius forKey:@"radius"];
    [_queryDictionary setObject:_when forKey:@"when"];
    [_queryDictionary setObject:_where forKey:@"where"];
    [_queryDictionary setObject:_what forKey:@"what"];
    [_queryDictionary setObject:_extraCriteria forKey:@"extraCriteria"];
}

- (void)resetView {
    [self.resultsArray removeAllObjects];
    self.currentEvents = 0;
    self.totalEvents = 0;
    self.tableView.tableFooterView = nil;
    [self.tableView setContentOffset:CGPointZero animated:YES];
    if (_currentLocation) {
        [self searchLocation];
    } else {
        [self setupHud];
        [self fetchEvents];
    }
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
    }
    return _locationManager;
}

- (NSMutableSet *)buildFQSet {
    NSMutableSet *fqSet = [[NSMutableSet alloc] init];
    
    if ([_extraCriteria valueForKey:@"0"]) {
        [fqSet addObject:@"agefrom:[* TO 11] OR keywords:\"ook voor kinderen\""];
    }
    
    if ([_extraCriteria valueForKey:@"1"]) {
        [fqSet addObject:@"price:0"];
    }
    
    if ([_extraCriteria valueForKey:@"2"]) {
        [fqSet addObject:@"-category_id:0.3.1.0.0"];
    }
    
    if ([_what count] != 0) {
        NSString *what = [NSString stringWithFormat:@"(%@)",[[[_what allValues] valueForKey:@"id"] componentsJoinedByString:@" OR "]];
        [fqSet addObject:[NSString stringWithFormat:@"category_id:(%@)", what]];
    }
    
    [fqSet addObject:@"type:event"];
    [fqSet addObject:@"language:nl"];
    
    return fqSet;
}

- (void)hideProblemView:(BOOL)hide withRemark:(NSString *)remark {
    _problemView.hidden = hide;
    _problemView.problemLabel.text = remark;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(!haveAlreadyReceivedCoordinates) {
        _location = [locations lastObject];
        [self fetchEvents];
    }
    [self.locationManager stopUpdatingLocation];
    
    haveAlreadyReceivedCoordinates = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.resultsArray removeAllObjects];
    [self.tableView reloadData];
    self.hud.hidden = YES;
    
    [self hideProblemView:NO withRemark:NSLocalizedString(@"NO LOCATION", @"")];
    
    self.tableView.showsInfiniteScrolling = NO;
    [self.tableView.pullToRefreshView stopAnimating];
}

#pragma mark - TableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.resultsArray.count) {
        return 112;
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    UiTDetailViewController *vc = (UiTDetailViewController *)segue.destinationViewController;
    vc.event = self.resultsArray[path.row];
}

#pragma mark - TableView DataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UiTDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UiTDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.resultsArray.count > 0) {
        UiTEvent *event = [self.resultsArray objectAtIndex:indexPath.row];
        
        cell.event = event;
        
        if (_currentLocation) {
            CLLocation *restoLocation = [[CLLocation alloc] initWithLatitude:event.latCoordinate
                                                                   longitude:event.lonCoordinate];
            
            CLLocationDistance meters = [restoLocation distanceFromLocation:_location];
            
            cell.distanceLabel.text = [NSString stringWithFormat:@"(%@)", [self getDistanceToResto:[NSNumber numberWithInt:(int) meters]]];
            [cell.distanceLabel sizeToFit];
        }
        
        [cell.favoriteButton addTarget:self action:@selector(favoriteEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.favoriteButton.tag = indexPath.row;
    }
    
    return cell;
}

- (NSString *)getDistanceToResto:(NSNumber *)distanceInMeters {
    NSString *distance;
    
    if (distanceInMeters && [distanceInMeters intValue] < 100000 && [distanceInMeters intValue] > 0) {
        if ([distanceInMeters intValue] < 1000) {
            distance = [NSString stringWithFormat:@"%dm", [distanceInMeters intValue]];
        }
        else {
            distance = [NSString stringWithFormat:@"%.2fkm", floor(([distanceInMeters floatValue] / 1000) * 100)/100];
        }
    }
    return distance;
}

- (void)favoriteEvent:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    
    NSString *cdbid = ((UiTEvent *)[self.resultsArray objectAtIndex:button.tag]).cdbid;
    
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

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
//        [_queryDictionary setObject:[[alertView textFieldAtIndex:0] text] forKey:@"title"];
        
        [_queryDictionary setObject:[self setupSaveQueryTitle] forKey:@"title"];
        
        NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
        
        if (context) {
            UiTSearchQuery *saveQuery = [UiTSearchQuery saveWithTitle:[self setupSaveQueryTitle] usingManagedObjectContext:context];
            
            if (saveQuery == nil) {
                
                UiTSearchQuery *newQuery = [UiTSearchQuery insertInManagedObjectContext:context];
                newQuery.title = [_queryDictionary valueForKey:@"title"];
                newQuery.searchTerm = [_queryDictionary valueForKey:@"searchTerm"];
                newQuery.radius = [_queryDictionary valueForKey:@"radius"];
                newQuery.when = [_queryDictionary valueForKey:@"when"];
                
                if ([[_queryDictionary valueForKey:@"extraCriteria"] valueForKey:@"0"]) {
                    newQuery.kidsValue = YES;
                }
                else {
                    newQuery.kidsValue = NO;
                }
                
                if ([[_queryDictionary valueForKey:@"extraCriteria"] valueForKey:@"1"]) {
                    newQuery.freeValue = YES;
                }
                else {
                    newQuery.freeValue = NO;
                }
                
                if ([[_queryDictionary valueForKey:@"extraCriteria"] valueForKey:@"2"]) {
                    newQuery.nocoursesandworkshopsValue = YES;
                }
                else {
                    newQuery.nocoursesandworkshops = NO;
                }
                
                if ([[_queryDictionary valueForKey:@"what"] count] > 0) {
                    NSMutableArray *eventTypeArray = [NSMutableArray array];
                    for (NSString *eventType in [_queryDictionary valueForKey:@"what"]) {
                        [eventTypeArray addObject:[NSString stringWithFormat:@"%@;%@;%@", eventType,
                                                   [[[_queryDictionary valueForKey:@"what"] valueForKey:eventType] valueForKey:@"id"],
                                                   [[[_queryDictionary valueForKey:@"what"] valueForKey:eventType] valueForKey:@"title"]]];
                    }
                    
                    newQuery.what = [eventTypeArray componentsJoinedByString:@","];
                }
                
                if ([[_queryDictionary valueForKey:@"where"] count] > 0) {
                    NSString *where = [NSString stringWithFormat:@"%@;%@;%@",
                                       [[[_queryDictionary valueForKey:@"where"] allKeys] firstObject],
                                       [[[[_queryDictionary valueForKey:@"where"] allValues] valueForKey:@"id"] firstObject],
                                       [[[[_queryDictionary valueForKey:@"where"] allValues] valueForKey:@"title"] firstObject]];
                    
                    newQuery.where = where;
                }
                
                [context save:nil];
                
                [self.saveButton setTitle:NSLocalizedString(@"SEARCHQUERY SAVED", @"") forState:UIControlStateNormal];
                self.saveButton.backgroundColor = UIColorFromHex(0x417505);
                self.closeButton.backgroundColor = UIColorFromHex(0x417505);
                [self.saveButton removeTarget:self action:@selector(saveSearchQueryAction) forControlEvents:UIControlEventTouchUpInside];
                
                [self performSelector:@selector(closeAction) withObject:nil afterDelay:1.5];
            } else {
                UIAlertView *saveQuery = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SAME TITLE SEARCHQUERY", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OKE", @"") otherButtonTitles:nil, nil] ;
                [saveQuery show];
            }
        }
    }
}

@end