//
//  UiTSearchModalViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 5/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTSearchModalViewController.h"
#import "UiTSearchWhatViewController.h"
#import "GoogleAnalyticsTracker.h"

@interface UiTSearchModalViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) NSArray *searchCriteria;
@property (strong, nonatomic) NSMutableDictionary *searchCriteriaDict;

@property (strong, nonatomic) NSString *categoryItems;

@end

enum SearchPossibilities {
    kSearchNearby = 0,
    kSearchCriteria
};

@implementation UiTSearchModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchCriteria = @[NSLocalizedString(@"ONLY FOR CHILDREN", @""), NSLocalizedString(@"ONLY FREE", @""), NSLocalizedString(@"NO COURSES AND WORKSHOPS", @"")];
    self.searchCriteriaDict = [[NSMutableDictionary alloc] init];
    
    [self setupView];
    [self setupTableView];
    
    [[GoogleAnalyticsTracker sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"SEARCHNEARBY", @"")];
}

- (void)checkSearchCriteria {
    NSMutableArray *selectedWhatItems = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"searchKids"] == YES) {
        [_searchCriteriaDict setObject:[_searchCriteria objectAtIndex:0] forKey:@"0"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"searchFree"] == YES) {
        [_searchCriteriaDict setObject:[_searchCriteria objectAtIndex:1] forKey:@"1"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"searchCoursesWorkshops"] == YES) {
        [_searchCriteriaDict setObject:[_searchCriteria objectAtIndex:2] forKey:@"2"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"searchWhat"] != nil) {
        NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchWhat"];
        for (NSMutableDictionary *category in dict) {
            [selectedWhatItems addObject:[[dict valueForKey:[NSString stringWithFormat:@"%@", category]] valueForKey:@"title"]];
        }
        _categoryItems = [selectedWhatItems componentsJoinedByString:@", "];
    }
}

- (void)setupView {
    self.title = NSLocalizedString(@"SEARCH", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [self.navigationItem setRightBarButtonItem:[self showRightBarButton:@"close"]];
}

- (UIBarButtonItem *)showRightBarButton:(NSString *)imageName {
    UIImage *barBtnImage = [UIImage imageNamed:imageName];
    UIImage *barBtnImageActive = [UIImage imageNamed:[NSString stringWithFormat:@"%@Highlighted", imageName]];
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [barButton setBackgroundImage:barBtnImage forState:UIControlStateNormal];
    [barButton setBackgroundImage:barBtnImageActive forState:UIControlStateHighlighted];
    
    [barButton setFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barBtnImage.size.width, barBtnImage.size.height)];
    
    [barButton addTarget:self action:@selector(closeModalView) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:barButton];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    return item;
}

- (void)closeModalView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), tableViewHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self setupFooterView];
}

- (void)setupFooterView {
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 70)];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 300, 50)];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setTitle:NSLocalizedString(@"SEARCH", @"") forState:UIControlStateNormal];
    [searchButton setBackgroundColor:BUTTONCOLOR];
    [searchButton setTintColor:[UIColor whiteColor]];
    [self.footerView addSubview:searchButton];
    
    self.tableView.tableFooterView = self.footerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [self checkSearchCriteria];
    [self.tableView reloadData];
}

- (void)search {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchModal" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kSearchNearby) {
        UiTSearchWhatViewController *searchWhatViewController = [[UiTSearchWhatViewController alloc] initWithExtensiveSearch:NO
                                                                                                                    andValue:nil];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", @"")
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
        [self.navigationController pushViewController:searchWhatViewController
                                             animated:YES];
    }
    else if (indexPath.section == kSearchCriteria) {
        if ([_searchCriteriaDict objectForKey:[NSString stringWithFormat:@"%li", (long)indexPath.row]]) {
            [_searchCriteriaDict removeObjectForKey:[NSString stringWithFormat:@"%li", (long)indexPath.row]];
            
            if (indexPath.row == 0) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"searchKids"];
            } else if (indexPath.row == 1) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"searchFree"];
            } else if (indexPath.row == 2) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"searchCoursesWorkshops"];
            }
        } else {
            [_searchCriteriaDict setObject:[_searchCriteria objectAtIndex:indexPath.row] forKey:[NSString stringWithFormat:@"%li", (long)indexPath.row]];
            
            if (indexPath.row == 0) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"searchKids"];
            } else if (indexPath.row == 1) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"searchFree"];
            } else if (indexPath.row == 2) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"searchCoursesWorkshops"];
            }
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_tableView reloadData];
    }
}

#pragma mark - TableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kSearchNearby)
        return NSLocalizedString(@"NEARBY", @"");
    else if (section == kSearchCriteria)
        return NSLocalizedString(@"EXTRA CRITERIA", @"");
    else return @"";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSearchNearby)
        return 1;
    else if (section == kSearchCriteria)
        return 3;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.section == kSearchNearby) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"WHAT", @"");
            cell.detailTextLabel.text = self.categoryItems;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if(indexPath.section == kSearchCriteria) {
        cell.textLabel.text = [self.searchCriteria objectAtIndex:indexPath.row];
        if ([self.searchCriteriaDict objectForKey:[NSString stringWithFormat:@"%li", (long)indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

@end