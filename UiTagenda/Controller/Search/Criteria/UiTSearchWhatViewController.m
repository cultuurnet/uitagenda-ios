//
//  UiTSearchWhatViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 5/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTSearchWhatViewController.h"
#import "UiTCategoriesAPIClient.h"

@interface UiTSearchWhatViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *searchCriteria;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) NSMutableArray *searchResults;
@end

@implementation UiTSearchWhatViewController

- (id)initWithExtensiveSearch:(BOOL)extensiveSearch andValue:(NSMutableDictionary *)values {
    self = [super init];
    if (self) {
        self.extensiveSearch = extensiveSearch;
        self.searchSelectedCriteria = values;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getEventTypes];
    
    self.searchResults = [[NSMutableArray alloc] init];
    
    if (!self.searchSelectedCriteria) {
        self.searchSelectedCriteria = [[NSMutableDictionary alloc] init];
    }
    
    if (!self.extensiveSearch) {
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"searchWhat"] != nil) {
            self.searchSelectedCriteria = [[[NSUserDefaults standardUserDefaults] valueForKey:@"searchWhat"] mutableCopy];
        }
    }
    
    [self setupView];
    [self setupTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CONFIRM", @"")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(confirmButtonSelected)];
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"SEARCH WHAT", @"")];
}

- (void)confirmButtonSelected {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupView {
    self.title = NSLocalizedString(@"WHAT", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
}

- (void)setupTableView {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self setupSearchBar];
}

- (void)setupSearchBar {
    self.searchBar.placeholder = NSLocalizedString(@"SEARCH", @"");
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                              contentsController:self];
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    [self.searchController setValue:NSLocalizedString(@"NO RESULTS FILTER", @"")
                             forKey:[@[@"no", @"Results", @"Message"] componentsJoinedByString:@""]];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
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

- (void)filterEventTypesForSearchText:(NSString *)searchText scope:(NSString *)scope {
    [self.searchResults removeAllObjects];
    NSPredicate *predictae = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    self.searchResults = [NSMutableArray arrayWithArray:[self.searchCriteria filteredArrayUsingPredicate:predictae]];
}

- (void)getEventTypes {
    self.searchCriteria = [self readFromFile];
}

- (NSArray *)readFromFile {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"categoriesEventTypes" ofType:@"plist"];
    return [[NSMutableArray alloc] initWithContentsOfFile:path];
}

#pragma mark - TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger rowIndex = indexPath.row;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSDictionary *searchDictionary = [self.searchResults objectAtIndex:indexPath.row];
        rowIndex = [self.searchCriteria indexOfObject:searchDictionary];
    }
    
    if ([_searchSelectedCriteria objectForKey:[NSString stringWithFormat:@"%li", (long)rowIndex]]) {
        [_searchSelectedCriteria removeObjectForKey:[NSString stringWithFormat:@"%li", (long)rowIndex]];
    }
    else {
        [_searchSelectedCriteria setObject:[_searchCriteria objectAtIndex:rowIndex]
                                    forKey:[NSString stringWithFormat:@"%li", (long)rowIndex]];
    }
    
    if (!self.extensiveSearch) {
        [[NSUserDefaults standardUserDefaults] setObject:self.searchSelectedCriteria forKey:@"searchWhat"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [_tableView reloadData];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    }
    return [self.searchCriteria count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([[self.searchSelectedCriteria allValues] containsObject:[self.searchResults objectAtIndex:indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = [[self.searchResults objectAtIndex:indexPath.row] valueForKey:@"title"];
    }
    else {
        cell.textLabel.text = [[self.searchCriteria objectAtIndex:indexPath.row] valueForKey:@"title"];
        if ([self.searchSelectedCriteria objectForKey:[NSString stringWithFormat:@"%li", (long)indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}


#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterEventTypesForSearchText:searchString
                                  scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterEventTypesForSearchText:self.searchDisplayController.searchBar.text
                                  scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

@end