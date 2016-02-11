//
//  UiTDjubbleViewController.m
//  UiTagenda
//
//  Created by Robbe Vandecasteele on 04/01/16.
//  Copyright © 2016 Cultuurnet. All rights reserved.
//

#import "UiTDjubbleViewController.h"
#import <ActionSheetPicker-3.0/ActionSheetPicker.h>
#import "UiTPlanAnEventDelegate.h"
#import "UiTOnGoingEventView.h"
#import "UiTFixedEventView.h"
#import "UiTTimeSpanEventView.h"

@interface UiTDjubbleViewController () <UiTPlanAnEventDelegate>

@property (nonatomic, strong) UIView *rootView;

@end

@implementation UiTDjubbleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (_typeEvent) {
        case UiTTypeEventOngoing: {
            UiTOnGoingEventView *rootView = [[[NSBundle mainBundle] loadNibNamed:@"OngoingEventView" owner:self options:nil] objectAtIndex:0];
            rootView.planAnEventDelegate = self;
            [self.view addSubview:rootView];
            _rootView = rootView;
        }
            break;
        case UiTTypeEventTimeSpan: {
            UiTTimeSpanEventView *rootView = [[[NSBundle mainBundle] loadNibNamed:@"TimeSpanEventView" owner:self options:nil] objectAtIndex:0];
            rootView.planAnEventDelegate = self;
            rootView.minDate = self.selectedEvent.dateFrom;
            rootView.maxDate = self.selectedEvent.dateTo;
            [self.view addSubview:rootView];
            _rootView = rootView;
        }
            break;
        case UiTTypeEventFixed: {
            UiTFixedEventView *rootView = [[[NSBundle mainBundle] loadNibNamed:@"FixedEventView" owner:self options:nil] objectAtIndex:0];
            rootView.planAnEventDelegate = self;
            rootView.possibleDates = self.selectedEvent.possibleDates;
            [self.view addSubview:rootView];
            _rootView = rootView;
        }
            break;
        default:
            break;
    }
}

#pragma mark - UiTPlanAnEvent Delegate Methods

- (void)dateSelected:(NSDate *)date {
    NSString *djubbleUrlString = [NSString stringWithFormat:@"djubble://add?lang=nl&subject=%@&location=%@&longitude=%f&latitude=%f&date=%@&source=uitagenda", [NSString stringWithFormat:@"%@ via UiTinVlaanderen.be", self.selectedEvent.title], self.selectedEvent.address, self.selectedEvent.lonCoordinate, self.selectedEvent.latCoordinate, [self getStringFromDate:date withFormat:@"yyyyMMddHHmm"]];
    
    NSString *encodedString = [djubbleUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *djubbleURL = [NSURL URLWithString:encodedString];
    
    if ([[UIApplication sharedApplication] canOpenURL:djubbleURL]) {
        [[UIApplication sharedApplication] openURL:djubbleURL];
    }
    
    [self cancelAction:nil];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.rootView.frame = self.view.bounds;
}

#pragma mark - Helper Methods

- (NSString *)getStringFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setLocale:[NSLocale currentLocale]];
    if (format.length <= 0) {
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
    } else {
        [dateFormat setDateFormat:format];
    }
    
    return date == nil ? @"" : [dateFormat stringFromDate:date];
}

@end