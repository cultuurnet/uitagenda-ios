//
//  UiTSearchWhenViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 6/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTSearchWhenViewController.h"

@interface UiTSearchWhenViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *searchCriteria;

@property (strong, nonatomic) NSString *value;

@end

@implementation UiTSearchWhenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(id)initWithValue:(NSString *)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupTableView];
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"SEARCH WHEN", @"")];
}

- (void)setupView {
    self.title = NSLocalizedString(@"WHEN", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.searchCriteria =  @[@"TODAY",
                             @"TOMORROW",
                             @"THISWEEKEND",
                             @"NEXTWEEKEND",
                             @"NEXT7DAYS",
                             @"NEXT30DAYS",
                             @"NEXT3MONTHS",
                             @"NEXT12MONTHS",
                             @"PERMANENT"];
}

-(void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), tableViewHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BACKGROUNDCOLOR;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

#pragma mark - TableView Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[self.searchCriteria objectAtIndex:indexPath.row] isEqualToString:_value]) {
        [_delegate setWhenValue:@""];
    }
    else {
        [_delegate setWhenValue:[self.searchCriteria objectAtIndex:indexPath.row]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [NSLocalizedString(@"WHEN", @"") uppercaseString];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchCriteria count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = NSLocalizedString([self.searchCriteria objectAtIndex:indexPath.row], @"");
    cell.textLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
    
    if ([[self.searchCriteria objectAtIndex:indexPath.row] isEqualToString:_value]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
