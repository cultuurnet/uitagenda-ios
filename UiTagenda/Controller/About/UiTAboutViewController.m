//
//  UiTAboutViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTAboutViewController.h"
#import "AFNetworking/AFNetworking.h"


@interface UiTAboutViewController ()

@property (strong, nonatomic) NSString *appInfo;

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation UiTAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupScrollView];
    [self getAboutInfo];
    
    [[UiTGlobalFunctions sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"ABOUT", @"")];
}

-(void)setupView {
    self.title = NSLocalizedString(@"ABOUT", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:[self showBarButton:@"favorite"], nil];
}

-(void)setupScrollView {
    self.scrollView = [[UIScrollView alloc ]initWithFrame:CGRectMake(0, 0, WIDTH(self.view), tableViewHeight)];
    self.scrollView.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:self.scrollView];
}

-(void)getAboutInfo {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://www.uitinvlaanderen.be/appinfo.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        self.appInfo = [jsonDict valueForKey:@"appinfo"];
        
        TTTAttributedLabel *appInfoLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, 10, WIDTH(self.view) - 20, 400)];
        appInfoLabel.delegate = self;
        appInfoLabel.backgroundColor = TABLEVIEWCOLOR;
        appInfoLabel.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink;
        appInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        appInfoLabel.textAlignment = NSTextAlignmentLeft;
        appInfoLabel.numberOfLines = 0;
        
        appInfoLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName: REDCOLOR,
                                          (id)kCTUnderlineStyleAttributeName : @(kCTUnderlineStyleNone)
                                          };
        
        appInfoLabel.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName: SLIDEMENUCOLOR,
                                                (id)kCTUnderlineStyleAttributeName: @(kCTUnderlineStyleNone)
                                                };
        
        appInfoLabel.font = [[UiTGlobalFunctions sharedInstance] customRegularFontWithSize:18];
        appInfoLabel.text = self.appInfo;

        [appInfoLabel sizeToFit];
        [self.scrollView addSubview:appInfoLabel];
        
        self.scrollView.contentSize = CGSizeMake(WIDTH(self.view), BOTTOM(appInfoLabel) + 10);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"")
                                    message:NSLocalizedString(@"SOMETHING WENT WRONG, INTERNET CONNECTION", @"")
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OKE", @"")
                          otherButtonTitles:nil, nil] show];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TTTAttributedLabel Delegated methods

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"T" withString:@""]]]];
}

@end