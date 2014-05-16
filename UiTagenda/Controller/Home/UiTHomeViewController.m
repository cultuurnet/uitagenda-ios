//
//  UiTHomeViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTHomeViewController.h"
#import "SVPullToRefresh/SVPullToRefresh.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "UiTAPIClient.h"
#import "UiTDetailViewController.h"
#import "UiTDetailCell.h"
#import "UiTEvent.h"
#import "UitagendaDataModel.h"
#import "UiTFavorite.h"
#import "UiTProblemView.h"

#import "NSMutableArray+UiTMap.h"

@interface UiTHomeViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@property (strong, nonatomic) NSMutableArray *resultsArray;
@property (nonatomic) NSInteger currentEvents, totalEvents;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UIImageView *noDataImageView;

@property (strong, nonatomic) UiTProblemView *problemView;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation UiTHomeViewController

static BOOL haveAlreadyReceivedCoordinates;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupTableView];
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"HOME", @"")];
}

-(void)viewWillAppear:(BOOL)animated {
    [_tableView reloadData];
}

-(void)setupView {
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
    self.hud.labelFont = [[UiTGlobalFunctions sharedInstance] customBoldFontWithSize:18];
    self.hud.detailsLabelFont = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
    [self.hud show:YES];
    [self.navigationController.view addSubview:self.hud];
}

-(void)resetView {
    [self.resultsArray removeAllObjects];
    self.currentEvents = 0;
    self.totalEvents = 0;
    self.tableView.tableFooterView = nil;
    [self searchLocation];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), tableViewHeight)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:self.tableView];
    
    __weak UiTHomeViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf resetView];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (haveAlreadyReceivedCoordinates) {
            [weakSelf fetchEvents];
        }
    }];
    
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"PULL TO REFRESH", @"") forState:SVPullToRefreshStateStopped];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"RELEASE TO REFRESH", @"") forState:SVPullToRefreshStateTriggered];
    [self.tableView.pullToRefreshView setTitle:NSLocalizedString(@"LOADING", @"") forState:SVPullToRefreshStateLoading];
    
    _problemView = [[UiTProblemView alloc] initWithFrame:CGRectMake(CENTER_IN_PARENT_X(self.tableView, 250), CENTER_IN_PARENT_Y(self.tableView, 250), 250, 250)];
    _problemView.hidden = YES;
    [_tableView addSubview:_problemView];
}

-(void)searchLocation {
    [self setupHud];
    haveAlreadyReceivedCoordinates = NO;
    [self.locationManager startUpdatingLocation];
}

-(void)fetchEvents {
    _problemView.hidden = YES;
    NSMutableSet *fqSet = [[NSMutableSet alloc] init];
    
    [fqSet addObject:@"-category_id:0.3.1.0.0"];
    [fqSet addObject:@"type:event"];
    [fqSet addObject:@"language:nl"];
    
    [[UiTAPIClient sharedClient] getPath:@"searchv2/search"
                           getParameters:@{@"q": @"*:*",
                                           @"group" : @"event",
                                           @"fq": fqSet,
                                           @"datetype": @"today",
                                           @"sfield" : @"physical_gis",
                                           @"d" : [NSString stringWithFormat:@"%i", (int)RADIUS],
                                           @"pt" : [NSString stringWithFormat:@"%f,%f",_location.coordinate.latitude, _location.coordinate.longitude],
                                           @"sort" : @"geodist() asc",
                                           @"rows" : [NSString stringWithFormat:@"%i", amountOfRows],
                                           @"start" : [NSString stringWithFormat:@"%i", self.currentEvents]}
                              completion:^(NSArray *results, NSError *error) {
                                  if (results) {
                                      NSMutableArray *resultsArray = [[results valueForKey:@"rootObject"] mutableCopy];
                                      
                                      self.totalEvents = [[[resultsArray firstObject] valueForKey:@"Long"] intValue];
                                      
                                      [resultsArray removeObjectAtIndex:0];
                                      
                                      [_resultsArray addObjectsFromArray:[resultsArray UiT_map:^UiTEvent*(NSDictionary *eventDictionary) {
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
                                      }
                                      else {
                                          self.tableView.showsInfiniteScrolling = YES;
                                      }
                                      
                                      if (self.totalEvents == 0) {
                                          self.tableView.tableFooterView = nil;
                                          [self hideProblemView:NO withRemark:NSLocalizedString(@"NO RESULTS", @"")];
                                      }
                                  } else {
                                      if (![_resultsArray count] > 0) {
                                          [self hideProblemView:NO withRemark:NSLocalizedString(@"SOMETHING WENT WRONG", @"")];
                                      }
                                      self.tableView.showsInfiniteScrolling = NO;
                                  }
                                  
                                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                  [self.tableView.pullToRefreshView stopAnimating];
                                  [self.tableView.infiniteScrollingView stopAnimating];
                                  [self.tableView reloadData];
                                  self.hud.hidden = YES;
                              }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

-(void)hideProblemView:(BOOL)hide withRemark:(NSString *)remark {
    _problemView.hidden = hide;
    _problemView.problemLabel.text = remark;
}

#pragma mark - CLLocationManagerDelegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(!haveAlreadyReceivedCoordinates) {
        _location = [locations lastObject];
        [self fetchEvents];
    }
    [self.locationManager stopUpdatingLocation];
    
    haveAlreadyReceivedCoordinates = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [_resultsArray removeAllObjects];
    [_tableView reloadData];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *detailViewController = [[UiTDetailViewController alloc] initWithEvent:(UiTEvent *)[self.resultsArray objectAtIndex:indexPath.row] andEventsArray:self.resultsArray];
    UiTDetailContainerViewController *detailContainer = [[UiTDetailContainerViewController alloc] initWithRootViewController:detailViewController];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", @"") style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:detailContainer animated:YES];
}

#pragma mark - TableView DataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UiTDetailCell *cell = (UiTDetailCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UiTDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([_resultsArray count] > 0) {
        
        UiTEvent *event = [self.resultsArray objectAtIndex:indexPath.row];
        
        cell.event = event;
        
        CLLocation *restoLocation = [[CLLocation alloc] initWithLatitude:event.latCoordinate
                                                               longitude:event.lonCoordinate];
        
        CLLocationDistance meters = [restoLocation distanceFromLocation:_location];
        
        
        //        if ([[NSNumber numberWithInt:(int) meters] intValue] > 100000 || [[NSNumber numberWithInt:(int) meters] intValue] == -1) {
        //            self.titleLabel.frame = CGRectMake(15, 0, 210, 45);
        //            [self.distanceLabel setText:@""];
        //        }
        
        cell.distanceLabel.text = [NSString stringWithFormat:@"(%@)", [self getDistanceToResto:[NSNumber numberWithInt:(int) meters]]];
        [cell.distanceLabel sizeToFit];
        [cell.favoriteButton addTarget:self action:@selector(favoriteEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.favoriteButton.tag = indexPath.row;
    }
    
    return cell;
}

-(NSString *)getDistanceToResto:(NSNumber *)distanceInMeters {
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

-(void)favoriteEvent:(id)sender {
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

@end