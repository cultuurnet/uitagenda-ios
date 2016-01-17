//
//  UiTAboutViewController.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTAboutViewController.h"
#import "AFNetworking/AFNetworking.h"

@interface UiTAboutViewController () <TTTAttributedLabelDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *appInfoLabel;

@end

@implementation UiTAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupScrollView];
    [self getAboutInfo];
    
    [[GoogleAnalyticsTracker sharedInstance] trackGoogleAnalyticsWithValue:NSLocalizedString(@"ABOUT", @"")];
}

- (void)setupView {
    self.title = NSLocalizedString(@"ABOUT", @"");
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.navigationItem.rightBarButtonItems = @[ [self showBarButtonWithType:UIBarButtonItemTypeFavorite] ];
}

- (void)setupScrollView {
    self.scrollView.backgroundColor = BACKGROUNDCOLOR;
}

- (void)getAboutInfo {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager GET:@"https://www.uitinvlaanderen.be/appinfo.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        
        self.appInfoLabel.delegate = self;
        self.appInfoLabel.backgroundColor = TABLEVIEWCOLOR;
        self.appInfoLabel.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink;
        self.appInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.appInfoLabel.textAlignment = NSTextAlignmentLeft;
        self.appInfoLabel.numberOfLines = 0;
        
        self.appInfoLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName: REDCOLOR,
                                             (id)kCTUnderlineStyleAttributeName : @(kCTUnderlineStyleNone)
                                             };
        
        self.appInfoLabel.activeLinkAttributes = @{(id)kCTForegroundColorAttributeName: SLIDEMENUCOLOR,
                                                   (id)kCTUnderlineStyleAttributeName: @(kCTUnderlineStyleNone)
                                                   };
        
        self.appInfoLabel.font = [UIFont customRegularFontWithSize:18];
        self.appInfoLabel.text = [jsonDict valueForKey:@"appinfo"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"")
                                    message:NSLocalizedString(@"SOMETHING WENT WRONG, INTERNET CONNECTION", @"")
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OKE", @"")
                          otherButtonTitles:nil, nil] show];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

#pragma mark - TTTAttributedLabel Delegated methods

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"T" withString:@""]]]];
}

@end