//
//  UiTMenuViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTMenuViewController.h"
#import "NVSlideMenuController/NVSlideMenuController.h"
#import "UiTMenu.h"
#import "UiTNavViewController.h"

@interface UiTMenuViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *menu;

@end

@implementation UiTMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SLIDEMENUCOLOR;
    
    self.menu = [UiTMenu sharedInstance];
    
    [self setupTableView];
}

-(void)setupTableView {
    self.tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), HEIGHT(self.view)) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Class ViewControllerClass = NSClassFromString([[self.menu objectAtIndex:indexPath.row] objectForKey:@"view"]);
    UIViewController *viewController = [[ViewControllerClass alloc] initWithNibName:nil bundle:nil];
    
    UiTNavViewController *navigationViewController = [[UiTNavViewController alloc] initWithNibName:nil bundle:nil];
    [navigationViewController setViewControllers:[[NSArray alloc] initWithObjects:viewController, nil]];
    [self.slideMenuController closeMenuBehindContentViewController:navigationViewController animated:YES bounce:NO completion:nil];
}

#pragma mark - TableView DataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:17];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = SLIDEMENUCOLOR;
        cell.backgroundColor = SLIDEMENUCOLOR;
        
        if (indexPath.row < [self.menu count] - 1) {
            [cell.layer addSublayer:[[UiTGlobalFunctions sharedInstance] createBorderWithX:15
                                                                                     withY:BOTTOM(cell) + 0.5
                                                                                 withWidth:WIDTH(cell)
                                                                                withHeight:0.5
                                                                                 withColor:[UIColor colorWithWhite:1 alpha:0.2]]];
        }
    }
    
    cell.textLabel.text = [[self.menu objectAtIndex:indexPath.row] objectForKey:@"title"];
    return cell;
}

@end