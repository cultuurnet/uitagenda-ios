//
//  UiTSearchWhereViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 6/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTSearchWhereViewController.h"
#import "UiTCategoriesAPIClient.h"

@interface UiTSearchWhereViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *searchCriteria, *searchResults;

@property (strong, nonatomic) NSMutableDictionary *values;

@property (strong, nonatomic) NSMutableArray *selectedValues;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;


@property (strong, nonatomic) NSMutableArray *lastSelectedSearchResults;

@end

@implementation UiTSearchWhereViewController

//-(id)initWithValue:(NSMutableDictionary *)values {
//    self = [super init];
//    if (self) {
//        _values = values;
//    }
//    return self;
//}

-(id)initWithValue:(NSMutableArray *)selectedValues {
    self = [super init];
    if (self) {
        _selectedValues = selectedValues;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self getRegions];
    self.searchCriteria = [self readFromFile];
    
    if (!self.values) {
        self.values = [[NSMutableDictionary alloc] init];
    }
    
    if (!self.selectedValues) {
        self.selectedValues = [[NSMutableArray alloc] init];
    }
    
    _lastSelectedSearchResults = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastSelectedSearchResults"] mutableCopy];
    
    if (_lastSelectedSearchResults == nil) {
        _lastSelectedSearchResults = [[NSMutableArray alloc] init];
    }
    
    [self setupView];
    [self setupTableView];
    [self setupSearchBar];
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"SEARCH WHERE", @"")];
}

- (void)setupView {
    self.title = NSLocalizedString(@"WHERE", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
}

-(void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), tableViewHeight)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:self.tableView];
}

-(void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), 44)];
    self.searchBar.placeholder = NSLocalizedString(@"SEARCH", @"");
    
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    [self.searchController setValue:NSLocalizedString(@"NO RESULTS FILTER", @"") forKey:[@[@"no", @"Results", @"Message"] componentsJoinedByString:@""]];
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    self.searchDisplayController.searchBar.showsCancelButton = YES;
    UIButton *cancelButton;
    UIView *topView = self.searchDisplayController.searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        [cancelButton setTitle:NSLocalizedString(@"CANCEL", @"") forState:UIControlStateNormal];
    }
}

-(void)filterEventTypesForSearchText:(NSString *)searchText scope:(NSString *)scope {
    [self.searchResults removeAllObjects];
    NSPredicate *predictae = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    self.searchResults = [NSMutableArray arrayWithArray:[self.searchCriteria filteredArrayUsingPredicate:predictae]];
}

-(void)getRegions {
    /*if (![[NSUserDefaults standardUserDefaults] boolForKey:@"getRegions"]) {
     [self fetchRegions];
     }
     else {*/
    self.searchCriteria = [self readFromFile];
    //    }
}

//-(void)fetchRegions {
//    NSMutableArray *allRegions = [[NSMutableArray alloc] init];
//    [[UiTCategoriesAPIClient sharedClient] getPath:@"flandersregion/classification/tojson" getParameters:nil completion:^(NSArray *results, NSError *error) {
//        if (results) {
//
//            NSArray *categories = [results valueForKeyPath:@"categorisation.term"];
//
//            for (NSDictionary *firstLevel in categories) {
//                NSArray *firstArray = [firstLevel valueForKey:@"term"];
//                for (NSDictionary *secondLevel in firstArray) {
//                    NSArray *secondArray = [secondLevel valueForKey:@"term"];
//                    for (NSDictionary *thirdLevel in secondArray) {
//                        NSArray *thirdArray = [thirdLevel valueForKey:@"term"];
//                        for (NSDictionary *fourtLevel in thirdArray) {
//                            [allRegions addObject:@{@"id" : [fourtLevel valueForKey:@"id"], @"title" : [fourtLevel valueForKey:@"label"]}];
//                        }
//                    }
//                }
//            }
//
////            self.searchCriteria = [self sortValues:allRegions];
//            [_tableView reloadData];
//
////            [self writeToFile:self.searchCriteria];
//        }
//        else {
//        }
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    }];
//}

//-(void)writeToFile:(NSMutableArray *)values {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"categoriesRegions.plist"];
//
//    NSMutableArray *sortedArray = [self sortValues:values];
//
//    if ([sortedArray writeToFile:path atomically:YES]) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"getRegions"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    self.searchCriteria = sortedArray;
//    [self.tableView reloadData];
//}
//
//-(NSMutableArray *)sortValues:(NSMutableArray *)values {
//    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByTitle];
//    return [[values sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
//}

-(NSMutableArray *)readFromFile {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"categoriesRegions" ofType:@"plist"];
    return [[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger rowIndex = indexPath.row;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *searchDictionary = [self.searchResults objectAtIndex:indexPath.row];
        rowIndex = [self.searchCriteria indexOfObject:searchDictionary];
    }
    
    if (tableView != self.searchDisplayController.searchResultsTableView && indexPath.section == 0) {
        if ([_selectedValues containsObject:[_lastSelectedSearchResults objectAtIndex:rowIndex]]) {
            [_selectedValues removeObject:[_lastSelectedSearchResults objectAtIndex:rowIndex]];
        }
        else {
            [_selectedValues removeAllObjects];
            [_selectedValues addObject:[_lastSelectedSearchResults objectAtIndex:rowIndex]];
        }
    }
    else {
        if ([_selectedValues containsObject:[_searchCriteria objectAtIndex:rowIndex]]) {
            [_selectedValues removeObject:[_searchCriteria objectAtIndex:rowIndex]];
        }
        else {
            if ([_lastSelectedSearchResults containsObject:[_searchCriteria objectAtIndex:rowIndex]]) {
                [_lastSelectedSearchResults removeObject:[_searchCriteria objectAtIndex:rowIndex]];
            }
            
            if ([_lastSelectedSearchResults count] == 5) {
                
                [_lastSelectedSearchResults removeObjectAtIndex:4];
            }
            
            [_selectedValues removeAllObjects];
            [_selectedValues addObject:[_searchCriteria objectAtIndex:rowIndex]];
            
            [_lastSelectedSearchResults insertObject:[_searchCriteria objectAtIndex:rowIndex] atIndex:0];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_lastSelectedSearchResults forKey:@"lastSelectedSearchResults"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_delegate setWhereValue:self.selectedValues];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return NSLocalizedString(@"ALL PLACES", @"");
    }
    else {
        if (section == 0) {
            if ([_lastSelectedSearchResults count] > 0) {
                return NSLocalizedString(@"FAVORITES", @"");
            }
        }
        else if (section == 1) {
            return NSLocalizedString(@"ALL PLACES", @"");
        }
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (section == 0) {
            return [_searchResults count];
        }
    }
    else {
        if (section == 0) {
            return [_lastSelectedSearchResults count];
        }
        else if (section == 1) {
            return [self.searchCriteria count];
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([_selectedValues containsObject:[self.searchResults objectAtIndex:indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = [[self.searchResults objectAtIndex:indexPath.row] valueForKey:@"title"];
    }
    else {
        if (indexPath.section == 0) {
            cell.textLabel.text = [[_lastSelectedSearchResults objectAtIndex:indexPath.row] valueForKey:@"title"];
            if ([_selectedValues containsObject:[_lastSelectedSearchResults objectAtIndex:indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else {
            cell.textLabel.text = [[self.searchCriteria objectAtIndex:indexPath.row] valueForKey:@"title"];
            if ([_selectedValues containsObject:[self.searchCriteria objectAtIndex:indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    return cell;
}
#pragma mark - UISearchDisplayController Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterEventTypesForSearchText:searchString
                                  scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterEventTypesForSearchText:self.searchDisplayController.searchBar.text
                                  scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

@end