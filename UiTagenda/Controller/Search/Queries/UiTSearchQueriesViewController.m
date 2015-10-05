//
//  UiTSearchQueriesViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTSearchQueriesViewController.h"
#import "UitagendaDataModel.h"
#import "UiTSearchQuery.h"
#import "UiTProblemView.h"

#import "UiTSearchResultsViewController.h"

@interface UiTSearchQueriesViewController ()
@property (strong, nonatomic) UiTProblemView *problemView;
@property (strong, nonatomic) NSString *currentDeleteTitle;
@property (nonatomic) BOOL currentlocation;
@property (nonatomic, strong) NSMutableDictionary *searchCriteriaDict;
@property (nonatomic, strong) NSMutableDictionary *what;
@property (nonatomic, strong) NSMutableDictionary *where;
@property (nonatomic, strong) UiTSearchQuery *selectedQuery;
@end

@implementation UiTSearchQueriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.navigationItem.rightBarButtonItems = @[ [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EDIT", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonSelected:)], [self showBarButtonWithType:UIBarButtonItemTypeFavorite] ];
    
    [self setupTableView];
    
    [self.tableView reloadData];
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"SEARCHQUERIES", @"")];
}

- (void)setupView {
    self.title = NSLocalizedString(@"SEARCHQUERIES", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
}

- (void)editButtonSelected:(id)sender {
    if (self.tableView.editing) {
        if (!TARGETED_DEVICE_IS_IPAD) {
            self.navigationItem.leftBarButtonItem = [self showBarButtonWithType:UIBarButtonItemTypeList];
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EDIT", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonSelected:)], [self showBarButtonWithType:UIBarButtonItemTypeFavorite], nil];
        [self.tableView setEditing:NO animated:YES];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"READY", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonSelected:)];
        self.navigationItem.rightBarButtonItems = @[];
        [self.tableView setEditing:YES animated:YES];
    }
}

- (void)setupTableView {
    self.tableView.backgroundColor = BACKGROUNDCOLOR;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    _problemView = [[UiTProblemView alloc] initWithFrame:CGRectMake(CENTER_IN_PARENT_X(self.tableView, 250), CENTER_IN_PARENT_Y(self.tableView, 250), 250, 250)];
    _problemView.hidden = YES;
    _problemView.problemLabel.text = NSLocalizedString(@"NO SEARCH QUERIES", @"");
    [self.tableView addSubview:_problemView];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [UiTSearchQuery entityInManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSSortDescriptor *idSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
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

#pragma markt - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSManagedObjectContext *context = [[UitagendaDataModel sharedDataModel] mainContext];
        
        if (context) {
            UiTSearchQuery *searchQuery = [UiTSearchQuery saveWithTitle:_currentDeleteTitle usingManagedObjectContext:context];
            if (searchQuery != nil) {
                [context deleteObject:searchQuery];
                [context save:nil];
            }
        }
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
        
        if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
            [self editButtonSelected:nil];
            _problemView.hidden = NO;
        }
    }
}

#pragma mark - TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UiTSearchQuery *searchQuery = ((UiTSearchQuery *)[[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row]);
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), CGFLOAT_MAX)];
    lbl.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
    lbl.numberOfLines = 0;
    lbl.text = [NSString stringWithFormat:@"%@", searchQuery.title];
    [lbl sizeToFit];
    return lbl.frame.size.height + 40;
    //    return 40;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UiTSearchQuery *query = (UiTSearchQuery *)[[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
        _currentDeleteTitle = query.title;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"DELETE SEARCH QUERY", @"")
                              message: [NSString stringWithFormat:@"Bent u zeker dat u de zoekopdracht \"%@\" wilt verwijderen?", _currentDeleteTitle]
                              delegate: self
                              cancelButtonTitle: NSLocalizedString(@"CANCEL", @"")
                              otherButtonTitles: NSLocalizedString(@"YES", @""), nil];
        [alert show];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedQuery = (UiTSearchQuery *)[[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    
    self.searchCriteriaDict = [[NSMutableDictionary alloc] init];
    
    if ([self.selectedQuery.free boolValue]){
        [self.searchCriteriaDict setObject:NSLocalizedString(@"ONLY FOR CHILDREN", @"") forKey:@"0"];
    }
    
    if ([self.selectedQuery.kids boolValue]) {
        [self.searchCriteriaDict setObject:NSLocalizedString(@"ONLY FREE", @"") forKey:@"1"];
    }
    
    if ([self.selectedQuery.nocoursesandworkshops boolValue]) {
        [self.searchCriteriaDict setObject:NSLocalizedString(@"NO COURSES AND WORKSHOPS", @"") forKey:@"2"];
    }
    
    NSString *radius = self.selectedQuery.radius;
    NSString *searchTerm = self.selectedQuery.searchTerm;
    NSString *when = self.selectedQuery.when;
    
    self.where = [[NSMutableDictionary alloc] init];
    NSArray *whereProperties = [self.selectedQuery.where componentsSeparatedByString:@";"];
    
    if ([whereProperties count] > 0) {
        [self.where setObject:@{@"id" : whereProperties[1], @"title" : whereProperties[2]} forKey:whereProperties[0]];
    }
    
    NSArray *whatItems = [self.selectedQuery.what componentsSeparatedByString:@","];
    self.what = [[NSMutableDictionary alloc] init];
    
    for (NSString *eventType in whatItems) {
        NSArray *whatProperties = [eventType componentsSeparatedByString:@";"];
        [self.what setObject:@{@"id" : whatProperties[1], @"title" : whatProperties[2]} forKey:whatProperties[0]];
    }
    
    self.currentlocation = YES;
    if (![[[[self.where allValues] valueForKey:@"id"] firstObject] isEqualToString:@"0000"]) {
        self.currentlocation = NO;
    }
    
//    UiTSearchResultsViewController *searchResultsVC = [[UiTSearchResultsViewController alloc]
//                                                       initWithSearchTerm:searchTerm
//                                                       withCurrentLocation:self.currentlocation
//                                                       withRadius:radius
//                                                       withWhen:when
//                                                       withWhere:self.where
//                                                       withWhat:self.what
//                                                       withExtraCriteria:self.searchCriteriaDict
//                                                       withSavedQuery:YES];
//    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", @"")
//                                                                             style:UIBarButtonItemStylePlain
//                                                                            target:nil
//                                                                            action:nil];
//    [self.navigationController pushViewController:searchResultsVC animated:YES];
    [self performSegueWithIdentifier:@"showResultsSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showResultsSegue"]) {
        UiTSearchResultsViewController *vc = (UiTSearchResultsViewController *)segue.destinationViewController;
        [vc setSearchTerm:self.selectedQuery.searchTerm
      withCurrentLocation:self.currentlocation
               withRadius:self.selectedQuery.radius
                 withWhen:self.selectedQuery.when
                withWhere:self.where
                 withWhat:self.what
        withExtraCriteria:self.searchCriteriaDict
           withSavedQuery:YES];
    }
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        _problemView.hidden = NO;
    }
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = ((UiTSearchQuery *)[[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row]).title;

    return cell;
}

@end