//
//  UiTDjubbleViewController.m
//  UiTagenda
//
//  Created by Robbe Vandecasteele on 04/01/16.
//  Copyright © 2016 Cultuurnet. All rights reserved.
//

#import "UiTDjubbleViewController.h"
#import <ActionSheetPicker-3.0/ActionSheetPicker.h>

@interface UiTDjubbleViewController ()
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) NSDate *selectedDate;
@end

@implementation UiTDjubbleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - IBActions

- (IBAction)dateAction:(id)sender {
    [ActionSheetDatePicker showPickerWithTitle:@"Datum"
                                datePickerMode:UIDatePickerModeDateAndTime
                                  selectedDate:[NSDate date]
                                   minimumDate:[NSDate date]
                                   maximumDate:nil
                                     doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                                         self.selectedDate = selectedDate;
                                         [self.dateButton setTitle:[self getStringFromDate:self.selectedDate withFormat:@"EEEE dd MMMM yyyy"]
                                                          forState:UIControlStateNormal];
                                     } cancelBlock:^(ActionSheetDatePicker *picker) {
                                         
                                     } origin:self.view];
}

- (IBAction)okAction:(id)sender {
    NSString *djubbleUrlString = [NSString stringWithFormat:@"djubble://add?lang=nlsubject=%@location=%@longitude=%flatitude=%fdate=%@source=uitagenda", self.selectedEvent.title, self.selectedEvent.address, self.selectedEvent.lonCoordinate, self.selectedEvent.latCoordinate, self.selectedEvent.calendarSummary];
    NSString *encodedString = [djubbleUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedString]];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper Methods

- (NSString *)getStringFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"nl_BE"]];
    if (format.length <= 0) {
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
    } else {
        [dateFormat setDateFormat:format];
    }
    
    return date == nil ? @"" : [dateFormat stringFromDate:date];
}

@end