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

@interface UiTSearchFilterViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) NSArray *searchCriteria;
@property (strong, nonatomic) NSMutableDictionary *searchCriteriaDict;

//@property (strong, nonatomic) NSMutableDictionary *where;

@property (strong, nonatomic) NSMutableArray *where;
@property (strong, nonatomic) NSString *radius;
@property (strong, nonatomic) NSString *when;
@property (strong, nonatomic) NSMutableDictionary *what;

@property (strong, nonatomic) UITextField *searchTermTextField;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (HEIGHT(self.view) < 500) {
        [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (HEIGHT(self.view) < 500) {
        CGRect rect = CGRectMake(0, 0, WIDTH(self.view), HEIGHT(self.view));
        rect.size.height = self.tableView.frame.size.height;
        [self.tableView scrollRectToVisible:rect animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.where = [[NSMutableArray alloc] init];
    self.radius = @"10";
    self.when = @"TODAY";
    self.what = [[NSMutableDictionary alloc] init];
    
    //    [_where setObject:@{@"id": @"0000", @"title": @"Huidige locatie" } forKey:@"0"];
    
    [_where addObject:@{@"id": @"0000", @"title": @"Huidige locatie" }];
    
    self.searchCriteria = @[NSLocalizedString(@"ONLY FOR CHILDREN", @""), NSLocalizedString(@"ONLY FREE", @""), NSLocalizedString(@"NO COURSES AND WORKSHOPS", @"")];
    self.searchCriteriaDict = [[NSMutableDictionary alloc] init];
    [_searchCriteriaDict setObject:[_searchCriteria objectAtIndex:2] forKey:[NSString stringWithFormat:@"%i", 2]];
    
    [self setupView];
    [self setupTableView];
    [self addTapGesture];
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"SEARCH", @"")];
}

- (void)setupView {
    self.title = NSLocalizedString(@"SEARCH", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: [self showBarButton:@"favorite"], nil];
}

-(void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), tableViewHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:self.tableView];
    
    [self setupFooterView];
}

- (void)setupFooterView {
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 70)];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 300, 50)];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setTitle:NSLocalizedString(@"SEARCH", @"") forState:UIControlStateNormal];
    [searchButton setBackgroundColor:REDCOLOR];
    [searchButton setTintColor:[UIColor whiteColor]];
    searchButton.titleLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:20];
    [self.footerView addSubview:searchButton];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)search {
    if (![_radius isEqualToString:@""] && [_where count] == 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"")
                                    message:NSLocalizedString(@"NO PLACE", @"")
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OKE", @"")
                          otherButtonTitles:nil] show];
    }
    else {
        BOOL currentlocation = YES;
        if (![[[_where firstObject] valueForKey:@"id"] isEqualToString:@"0000"]) {
            currentlocation = NO;
        }
        
        NSMutableDictionary *where = [[NSMutableDictionary alloc] init];
        
        if ([_where count] == 1) {
            [where setObject:@{@"id": [[_where firstObject] valueForKey:@"id"], @"title": [[_where firstObject] valueForKey:@"title"] } forKey:@"0"];
            
            
            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
                                                                                                action:@"Waar"
                                                                                                 label:[[_where firstObject] valueForKey:@"title"]
                                                                                                 value:nil] build]];
            
        }
        
        if ([[[_where firstObject] valueForKey:@"id"] isEqualToString:@"000000"]) {
            [where removeAllObjects];
        }

        UiTSearchResultsViewController *searchResultsVC = [[UiTSearchResultsViewController alloc]
                                                           initWithSearchTerm:self.searchTermTextField.text
                                                           withCurrentLocation:currentlocation
                                                           withRadius:_radius
                                                           withWhen:[_when isEqualToString:@""] ? @"" : [_when lowercaseString]
                                                           withWhere:where
                                                           withWhat:_what
                                                           withExtraCriteria:_searchCriteriaDict
                                                           withSavedQuery:NO];
        
        
        
        
        [self trackAllSearchActions];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", @"") style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:searchResultsVC animated:YES];
    }
}

-(void)trackAllSearchActions {
    if (![_when isEqualToString:@""]) {
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
                                                                                            action:@"Wanneer"
                                                                                             label:NSLocalizedString(_when, @"")
                                                                                             value:nil] build]];
    }
    
    if (![self.searchTermTextField.text isEqualToString:@""]) {
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
                                                                                            action:@"Zoekveld"
                                                                                             label:self.searchTermTextField.text
                                                                                             value:nil] build]];
    }
    
    
    if (![_radius isEqualToString:@""]) {
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
                                                                                            action:@"Straal"
                                                                                             label:_radius
                                                                                             value:nil] build]];
    }
    
    if ([_what count] > 0) {
        for (NSString *eventType in [[_what allValues] valueForKey:@"title"]) {
            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
                                                                                                action:@"Wat"
                                                                                                 label:eventType
                                                                                                 value:nil] build]];
        }
    }
    
    if ([_searchCriteriaDict count] > 0) {
        for (NSString *extraCriteria in [_searchCriteriaDict allValues]) {
            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Uitgebreid zoeken"
                                                                                                action:@"Extra zoekcriteria"
                                                                                                 label:extraCriteria
                                                                                                 value:nil] build]];
        }
    }
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

-(void)openFavoritesModal {
    UiTFavoritesViewController *favoritesViewController = [[UiTFavoritesViewController alloc] initWithModal:YES];
    UiTNavViewController *navViewController = [[UiTNavViewController alloc] initWithRootViewController:favoritesViewController];
    [self presentViewController:navViewController animated:YES completion:nil];
}

#pragma mark - TableView Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kSearchCriteria) {
        if (indexPath.row == kSearchWhere) {
            UiTSearchWhereViewController *whereViewController = [[UiTSearchWhereViewController alloc] initWithValue:_where];
            whereViewController.delegate = self;
            [self pushViewController:whereViewController];
        }
        else if (indexPath.row == kSearchRadius) {
            UiTSearchRadiusViewController *radiusViewController = [[UiTSearchRadiusViewController alloc] initWithValue:_radius];
            radiusViewController.delegate = self;
            [self pushViewController:radiusViewController];
        }
        else if (indexPath.row == kSearchWhen) {
            UiTSearchWhenViewController *whenViewController = [[UiTSearchWhenViewController alloc] initWithValue:_when];
            whenViewController.delegate = self;
            [self pushViewController:whenViewController];
        }
        else if (indexPath.row == kSearchWhat) {
            UiTSearchWhatViewController *whatViewController = [[UiTSearchWhatViewController alloc] initWithExtensiveSearch:YES andValue:_what];
            [self pushViewController:whatViewController];
        }
        else {
            
        }
    }
    else if (indexPath.section == kSearchExtraCriteria) {
        if ([_searchCriteriaDict objectForKey:[NSString stringWithFormat:@"%i", indexPath.row]]) {
            [_searchCriteriaDict removeObjectForKey:[NSString stringWithFormat:@"%i", indexPath.row]];
        }
        else {
            [_searchCriteriaDict setObject:[_searchCriteria objectAtIndex:indexPath.row] forKey:[NSString stringWithFormat:@"%i", indexPath.row]];
        }
    }
    else {
        
    }
    [_tableView reloadData];
}

-(void)pushViewController:(UIViewController *)viewController {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", @"") style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Own Delegate methods

-(void)setWhereValue:(NSMutableArray *)value {
    _where = value;
    
    if ([_where count] == 0) {
        [_where addObject:@{@"id": @"000000", @"title": @"Alle locaties" }];
    }
    
    [self.tableView reloadData];
}

-(void)setRadiusValue:(NSString *)value {
    _radius = value;
    [self.tableView reloadData];
}

-(void)setWhenValue:(NSString *)value {
    _when = value;
    [self.tableView reloadData];
}

-(void)setWhatValue:(NSMutableDictionary *)values {
    _what = values;
    [self.tableView reloadData];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == kSearchCriteria)
//        return NSLocalizedString(@"NEARBY", @"");
//    else if (section == kSearchExtraCriteria)
//        return NSLocalizedString(@"EXTRA CRITERIA", @"");
//    else return @"";
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 10;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 10;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSearchCriteria)
        return 5;
    else if (section == kSearchExtraCriteria)
        return 3;
    else
        return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.section == kSearchCriteria) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == kSearchInput) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.searchTermTextField = (UITextField *)[cell.contentView viewWithTag:1];
            
            if (!self.searchTermTextField) {
                self.searchTermTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, CENTER_IN_PARENT_Y(cell.contentView, 35), 290, 35)];
            }
            
            self.searchTermTextField.delegate = self;
            self.searchTermTextField.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
            self.searchTermTextField.placeholder = NSLocalizedString(@"SEARCHTERM", @"");
            self.searchTermTextField.tag = 1;
            self.searchTermTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell.contentView addSubview:self.searchTermTextField];
        }
        else if (indexPath.row == kSearchWhere) {
            cell.textLabel.text = NSLocalizedString(@"WHERE", @"");
            //            cell.detailTextLabel.text = [self createLabelCell:_where];
            if ([_where count] == 1) {
                cell.detailTextLabel.text = [[_where firstObject] valueForKey:@"title"];
            }
            else {
                cell.detailTextLabel.text = @"";
            }
            
            cell.textLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
            cell.detailTextLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
        }
        else if (indexPath.row == kSearchRadius) {
            cell.textLabel.text = NSLocalizedString(@"RADIUS", @"");
            cell.textLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
            cell.detailTextLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
            if (![_radius isEqualToString:@""]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ km", _radius];
            }
            else {
                cell.detailTextLabel.text = @"";
            }
        }
        else if (indexPath.row == kSearchWhen) {
            cell.textLabel.text = NSLocalizedString(@"WHEN", @"");
            cell.detailTextLabel.text = NSLocalizedString(_when, @"");
            cell.textLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
            cell.detailTextLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
        }
        else if (indexPath.row == kSearchWhat) {
            cell.textLabel.text = NSLocalizedString(@"WHAT", @"");
            
            if ([_what count] == 0) {
                cell.detailTextLabel.text = NSLocalizedString(@"ALL", @"");
            }
            else {
                cell.detailTextLabel.text = [self createLabelCell:_what];
            }
            
            cell.textLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
            cell.detailTextLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
        }
        else {
            
        }
    }
    else if(indexPath.section == kSearchExtraCriteria) {
        cell.textLabel.text = [self.searchCriteria objectAtIndex:indexPath.row];
        cell.textLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
        if ([self.searchCriteriaDict objectForKey:[NSString stringWithFormat:@"%i", indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

-(NSString *)createLabelCell:(NSMutableDictionary *)values {
    NSMutableArray *selectedItems = [NSMutableArray array];
    for (NSMutableDictionary *item in values) {
        [selectedItems addObject:[[values valueForKey:[NSString stringWithFormat:@"%@", item]] valueForKey:@"title"]];
    }
    return [selectedItems componentsJoinedByString:@", "];
}

#pragma mark - UITextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end