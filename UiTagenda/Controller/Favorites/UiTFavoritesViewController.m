//
//  UiTFavoritesViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTFavoritesViewController.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "UiTFavorite.h"
#import "UiTAPIClient.h"
#import "UiTEvent.h"
#import "UiTDetailCell.h"
#import "UitagendaDataModel.h"
#import "UiTDetailViewController.h"
#import "UiTProblemView.h"
#import "UiTDetailContainerViewController.h"

#import "NSMutableArray+UiTMap.h"
#import "ArrayDataSource.h"
#import "UiTDetailCell+UiTFavorite.h"

@interface UiTFavoritesViewController () <UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *resultsArray, *eventIDs;
@property (strong, nonatomic) UIImageView *noFavoritesImageView;
@property (strong, nonatomic) UiTProblemView *problemView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) ArrayDataSource *dataSource;
@end

@implementation UiTFavoritesViewController

- (id)initWithModal:(BOOL)modal {
    self = [super init];
    if (self) {
        self.modal = modal;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.fetchedResultsController performFetch:nil];
    [self getAllFavoriteEventIds];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupTableView];
    [self setupDatasource];
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"FAVORITES", @"")];
}

- (void)setupView {
    [self setupHud];
    self.title = NSLocalizedString(@"FAVORITES", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
    
    if (self.modal) {
        UIBarButtonItem *btnClose = [self showBarButtonWithType:UIBarButtonItemTypeClose];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: btnClose, nil]];
        [self.navigationItem setLeftBarButtonItem:nil];
    } else {
        self.navigationItem.rightBarButtonItems = nil;
    }
    
    _eventIDs = [NSMutableArray array];
    _resultsArray = [NSMutableArray array];
}

- (void)setupTableView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.canCancelContentTouches = YES;
    self.tableView.backgroundColor = BACKGROUNDCOLOR;
    
    _problemView = [[UiTProblemView alloc] initWithFrame:CGRectMake(CENTER_IN_PARENT_X(self.tableView, 250), CENTER_IN_PARENT_Y(self.tableView, 250), 250, 250)];
    _problemView.hidden = YES;
    [self.tableView addSubview:_problemView];
}

- (void)setupDatasource {
    self.dataSource = [[ArrayDataSource alloc] initWithItems:self.resultsArray
                                              cellIdentifier:@"CellIdentifier"
                                          configureCellBlock:^(UiTDetailCell *cell, UiTEvent *event) {
        [cell configureForEvent:event withAllEvents:_resultsArray];
        [cell.favoriteButton addTarget:self action:@selector(favoriteThisEventAction:) forControlEvents:UIControlEventTouchUpInside];
        }];
    
    self.tableView.dataSource = self.dataSource;
}

- (void)setupHud {
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.dimBackground = YES;
    self.hud.labelText = NSLocalizedString(@"LOADING FAVORITES", @"");
    self.hud.detailsLabelText = NSLocalizedString(@"LOADING MESSAGE", @"");
    self.hud.labelFont = [[UiTGlobalFunctions sharedInstance] customBoldFontWithSize:18];
    self.hud.detailsLabelFont = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:16];
    [self.hud show:YES];
    [self.navigationController.view addSubview:self.hud];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [UiTFavorite entityInManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSSortDescriptor *idSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventID" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[idSortDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:context
                                                                                                  sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        abort();
	}
    
    return _fetchedResultsController;
}

- (void)getAllFavoriteEventIds {
    [_eventIDs removeAllObjects];
    [_resultsArray removeAllObjects];
    
    for (UiTFavorite *fav in [self.fetchedResultsController fetchedObjects]) {
        [_eventIDs addObject:fav.eventID];
    }
    
    [self fetchEvents];
}

- (void)fetchEvents {
    if ([_eventIDs count] > 0) {
        _problemView.hidden = YES;
        NSString *eventIDs = [NSString stringWithFormat:@"cdbid:\"%@\"", [_eventIDs componentsJoinedByString:@"\" OR \""]];
        [[UiTAPIClient sharedClient] getPath:@"searchv2/search"
                               getParameters:@{@"q": eventIDs,
                                               @"group" : @"event",
                                               @"past" : @"true",
                                               @"sort" : @"startdate asc"}
                                  completion:^(NSArray *results, NSError *error) {
                                      if (results) {
                                          NSMutableArray *resultsArray = [[results valueForKey:@"rootObject"] mutableCopy];
                                          [resultsArray removeObjectAtIndex:0];
                                          
                                          [_resultsArray addObjectsFromArray:[resultsArray UiT_map:^UiTEvent*(NSDictionary *eventDictionary) {
                                              return [[UiTEvent alloc] initWithDictionary:eventDictionary];
                                          }]];
                                      } else {
                                          [self hideProblemView:NO withRemark:NSLocalizedString(@"SOMETHING WENT WRONG", @"")];
                                      }
                                      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                      [self.tableView reloadData];
                                      self.hud.hidden = YES;
                                  }];
    } else {
        [self.tableView reloadData];
        [self hideProblemView:NO withRemark:NSLocalizedString(@"NO FAVORITES", @"")];
        self.hud.hidden = YES;
    }
}

- (void)hideProblemView:(BOOL)hide withRemark:(NSString *)remark {
    _problemView.hidden = hide;
    _problemView.problemLabel.text = remark;
}

#pragma mark - IBActions

- (IBAction)favoriteThisEventAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    
    NSString *cdbid = ((UiTEvent *)[self.resultsArray objectAtIndex:button.tag]).cdbid;
    
    if (button.selected) {
        [button removeTarget:self action:@selector(favoriteThisEventAction:) forControlEvents:UIControlEventTouchUpInside];
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
    
    [self.resultsArray removeObjectAtIndex:button.tag];
    [self.tableView reloadData];
    
    if (![_resultsArray count] > 0) {
        [self hideProblemView:NO withRemark:NSLocalizedString(@"NO FAVORITES", @"")];
    }
}

#pragma mark - TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    UiTDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"homeDetailVC"];
    UiTDetailContainerViewController *contVc = [[UiTDetailContainerViewController alloc] initWithRootViewController:vc];
    vc.event = self.resultsArray[indexPath.row];
    vc.eventsArray = self.resultsArray;
    [self.navigationController pushViewController:contVc animated:YES];
}

@end