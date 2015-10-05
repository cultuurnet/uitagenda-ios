//
//  UiTMenuViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTMenuViewController.h"
#import "UiTMenu.h"
#import "UiTNavViewController.h"
#import "CustomSplitViewController.h"
#import "UiTBaseViewController.h"

#import "NVSlideMenuController/NVSlideMenuController.h"

@interface UiTMenuViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *menu;

@end

@implementation UiTMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SLIDEMENUCOLOR;
    
    self.menu = [UiTMenu sharedInstance];
    
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, HEIGHT(self.view)) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - TableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *storyboardName = [self.menu[indexPath.row] valueForKey:kStoryboardTitle];
    
    if (storyboardName.length > 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
        UIViewController *contentViewController = [storyboard instantiateInitialViewController];
        
        if (TARGETED_DEVICE_IS_IPAD) {
            NSMutableArray *viewControllerArray = [[NSMutableArray alloc] initWithArray:[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers]];
            self.splitViewController.delegate = (UiTBaseViewController *)contentViewController;
            [viewControllerArray removeAllObjects];
            [viewControllerArray addObject:contentViewController];
            [[self.splitViewController.viewControllers objectAtIndex:1] setViewControllers:viewControllerArray animated:NO];
        } else {
            UiTNavViewController *navigationViewController = [[UiTNavViewController alloc] init];
            navigationViewController.viewControllers = @[ contentViewController ];
            [self.slideMenuController closeMenuBehindContentViewController:navigationViewController animated:YES bounce:NO completion:nil];
        }
    }
    
//    Class ViewControllerClass = NSClassFromString([[self.menu objectAtIndex:indexPath.row] objectForKey:kMenuViewController]);
//    UIViewController *viewController = [[ViewControllerClass alloc] initWithNibName:nil bundle:nil];
//    
//    UiTNavViewController *navigationViewController = [[UiTNavViewController alloc] initWithNibName:nil bundle:nil];
//    [navigationViewController setViewControllers:[[NSArray alloc] initWithObjects:viewController, nil]];
//    [self.slideMenuController closeMenuBehindContentViewController:navigationViewController animated:YES bounce:NO completion:nil];
}

#pragma mark - TableView DataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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