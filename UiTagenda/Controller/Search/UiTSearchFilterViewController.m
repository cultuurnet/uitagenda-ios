//
//  UiTSearchFilterViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTSearchFilterViewController.h"
#import "UiTFavoritesViewController.h"
#import "UiTNavViewController.h"
#import "UiTSearchResultsViewController.h"
#import "UiTAPIClient.h"

@interface UiTSearchFilterViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) NSArray *searchCriteria;
@property (strong, nonatomic) NSMutableDictionary *searchCriteriaDict;
@property (strong, nonatomic) NSMutableArray *where;
@property (strong, nonatomic) NSString *radius;
@property (strong, nonatomic) NSString *when;
@property (strong, nonatomic) NSMutableDictionary *what;
@property (strong, nonatomic) IBOutlet UITextField *searchTermTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) NSMutableDictionary *whereDic;
@property (nonatomic) BOOL currentLocation;
@end

enum SearchPossibilities {
    kSearchCriteria = 0,
    kSearchExtraCriteria
};

enum SearchCriteria {
    kSearchWhere = 0,
    kSearchRadius,
    kSearchWhen,
    kSearchWhat,
    kSearchInput
};

@implementation UiTSearchFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.where = [[NSMutableArray alloc] init];
    self.radius = @"10";
    self.when = @"TODAY";
    self.what = [[NSMutableDictionary alloc] init];
    
    [_where addObject:@{@"id": @"0000", @"title": @"Huidige locatie" }];
    
    self.searchCriteria = @[NSLocalizedString(@"ONLY FOR CHILDREN", @""), NSLocalizedString(@"ONLY FREE", @""), NSLocalizedString(@"NO COURSES AND WORKSHOPS", @"")];
    self.searchCriteriaDict = [[NSMutableDictionary alloc] init];
    [_searchCriteriaDict setObject:[_searchCriteria objectAtIndex:2] forKey:[NSString stringWithFormat:@"%i", 2]];
    
    [self setupView];
    [self setupTableView];
    [self addTapGesture];
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"SEARCH", @"")];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)setupView {
    self.title = NSLocalizedString(@"SEARCH", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.navigationItem.rightBarButtonItems = @[ [self showBarButtonWithType:UIBarButtonItemTypeFavorite] ];
}

- (void)setupTableView {
    self.tableView.backgroundColor = BACKGROUNDCOLOR;
    [self setupFooterView];
}

- (void)setupFooterView {
    [self.searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.searchButton setTitle:NSLocalizedString(@"SEARCH", @"") forState:UIControlStateNormal];
    [self.searchButton setBackgroundColor:REDCOLOR];
    [self.searchButton setTintColor:[UIColor whiteColor]];
    self.searchButton.titleLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:20];
    self.tableView.tableFooterView = self.footerView;
}

- (void)addTapGesture {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)hideKeyboard {
    [self.searchTermTextField resignFirstResponder];
}

- (void)searchAction {
    if (![_radius isEqualToString:@""] && [_where count] == 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"")
                                    message:NSLocalizedString(@"NO PLACE", @"")
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OKE", @"")
                          otherButtonTitles:nil] show];
    } else {
        self.currentLocation = YES;
        if (![[[_where firstObject] valueForKey:@"id"] isEqualToString:@"0000"]) {
            self.currentLocation = NO;
        }
        
        
        if ([_where count] == 1) {
            [self.whereDic setObject:@{@"id": [[_where firstObject] valueForKey:@"id"], @"title": [[_where firstObject] valueForKey:@"title"] } forKey:@"0"];
            
            
//            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
//                                                                                                action:@"Waar"
//                                                                                                 label:[[_where firstObject] valueForKey:@"title"]
//                                                                                                 value:nil] build]];

        }
        
        if ([[[_where firstObject] valueForKey:@"id"] isEqualToString:@"000000"]) {
            [self.whereDic removeAllObjects];
        }
        
        [self trackAllSearchActions];
        [self performSegueWithIdentifier:@"showResultSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showResultSegue"]) {
        UiTSearchResultsViewController *vc = (UiTSearchResultsViewController *)segue.destinationViewController;
        [vc setSearchTerm:self.searchTermTextField.text
      withCurrentLocation:self.currentLocation
               withRadius:_radius
                 withWhen:[_when isEqualToString:@""] ? @"" : [_when lowercaseString]
                withWhere:self.whereDic
                 withWhat:_what
        withExtraCriteria:_searchCriteriaDict
           withSavedQuery:NO];
    } else if ([segue.identifier isEqualToString:@"radiusSegue"]) {
        UiTSearchRadiusViewController *vc = (UiTSearchRadiusViewController *)segue.destinationViewController;
        vc.value = _radius;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"whenSegue"]) {
        UiTSearchWhenViewController *vc = (UiTSearchWhenViewController *)segue.destinationViewController;
        vc.value = _when;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"whereSegue"]) {
        UiTSearchWhereViewController *vc = (UiTSearchWhereViewController *)segue.destinationViewController;
        vc.selectedValues = _where;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"whatSegue"]) {
        UiTSearchWhatViewController *vc = (UiTSearchWhatViewController *)segue.destinationViewController;
        vc.extensiveSearch = YES;
        vc.searchSelectedCriteria = _what;
    }
}

- (void)trackAllSearchActions {
    if (![_when isEqualToString:@""]) {
//        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
//                                                                                            action:@"Wanneer"
//                                                                                             label:NSLocalizedString(_when, @"")
//                                                                                             value:nil] build]];
    }
    
    if (![self.searchTermTextField.text isEqualToString:@""]) {
//        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
//                                                                                            action:@"Zoekveld"
//                                                                                             label:self.searchTermTextField.text
//                                                                                             value:nil] build]];
    }
    
    
    if (![_radius isEqualToString:@""]) {
//        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
//                                                                                            action:@"Straal"
//                                                                                             label:_radius
//                                                                                             value:nil] build]];
    }
    
    if ([_what count] > 0) {
        for (NSString *eventType in [[_what allValues] valueForKey:@"title"]) {
//            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
//                                                                                                action:@"Wat"
//                                                                                                 label:eventType
//                                                                                                 value:nil] build]];
        }
    }
    
    if ([_searchCriteriaDict count] > 0) {
        for (NSString *extraCriteria in [_searchCriteriaDict allValues]) {
//            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
//                                                                                                action:@"Extra zoekcriteria"
//                                                                                                 label:extraCriteria
//                                                                                                 value:nil] build]];
        }
    }
}

#pragma mark - TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kSearchExtraCriteria) {
        if ([_searchCriteriaDict objectForKey:[NSString stringWithFormat:@"%li", (long)indexPath.row]]) {
            [_searchCriteriaDict removeObjectForKey:[NSString stringWithFormat:@"%li", (long)indexPath.row]];
        } else {
            [_searchCriteriaDict setObject:[_searchCriteria objectAtIndex:indexPath.row] forKey:[NSString stringWithFormat:@"%li", (long)indexPath.row]];
        }
    }
    [self.tableView reloadData];
}

- (void)pushViewController:(UIViewController *)viewController {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", @"") style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - TableView DataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.section == kSearchCriteria) {
        if (indexPath.row == kSearchInput) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.searchTermTextField.delegate = self;
            self.searchTermTextField.tag = 1;
            self.searchTermTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        } else if (indexPath.row == kSearchWhere) {
            if ([_where count] == 1) {
                cell.detailTextLabel.text = [[_where firstObject] valueForKey:@"title"];
            } else {
                cell.detailTextLabel.text = @"";
            }
        } else if (indexPath.row == kSearchRadius) {
            if (![_radius isEqualToString:@""]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ km", _radius];
            } else {
                cell.detailTextLabel.text = @"";
            }
        } else if (indexPath.row == kSearchWhen) {
            cell.detailTextLabel.text = NSLocalizedString(_when, @"");
        } else if (indexPath.row == kSearchWhat) {
            if (_what.count > 0) {
                cell.detailTextLabel.text = [self createLabelCell:_what];
            }
        }
    } else if (indexPath.section == kSearchExtraCriteria) {
        if ([self.searchCriteriaDict objectForKey:[NSString stringWithFormat:@"%li", (long)indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (NSString *)createLabelCell:(NSMutableDictionary *)values {
    NSMutableArray *selectedItems = [NSMutableArray array];
    for (NSMutableDictionary *item in values) {
        [selectedItems addObject:[[values valueForKey:[NSString stringWithFormat:@"%@", item]] valueForKey:@"title"]];
    }
    return [selectedItems componentsJoinedByString:@", "];
}

#pragma mark - Own Delegate methods

- (void)setWhereValue:(NSMutableArray *)value {
    _where = value;
    
    if ([_where count] == 0) {
        [_where addObject:@{ @"id": @"000000", @"title": @"Alle locaties" }];
    }
    
    [self.tableView reloadData];
}

- (void)setRadiusValue:(NSString *)value {
    _radius = value;
    [self.tableView reloadData];
}

- (void)setWhenValue:(NSString *)value {
    _when = value;
    [self.tableView reloadData];
}

- (void)setWhatValue:(NSMutableDictionary *)values {
    _what = values;
    [self.tableView reloadData];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end