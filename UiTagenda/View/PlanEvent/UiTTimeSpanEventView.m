//
//  UiTTimeSpanEventView.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 16/01/16.
//  Copyright © 2016 Cultuurnet. All rights reserved.
//

#import "UiTTimeSpanEventView.h"
#import <ActionSheetPicker-3.0/ActionSheetPicker.h>
#import "NSDate+UiTDate.h"

@interface UiTTimeSpanEventView ()

@property (weak, nonatomic) IBOutlet UILabel *dateBetweenLabel;

@property (weak, nonatomic) IBOutlet UILabel *chooseADateTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *pickDayButton;
@property (weak, nonatomic) IBOutlet UIButton *pickHourButton;
@property (weak, nonatomic) IBOutlet UIButton *planEventButton;

@property (nonatomic, strong) NSDate *day;
@property (nonatomic, strong) NSDate *hour;

@end

@implementation UiTTimeSpanEventView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.chooseADateTitleLabel.font = [UIFont customBoldFontWithSize:20];
    self.pickDayButton.titleLabel.font = [UIFont customRegularFontWithSize:18];
    self.pickHourButton.titleLabel.font = [UIFont customRegularFontWithSize:18];
    self.dateBetweenLabel.font = [UIFont customRegularFontWithSize:18];
    
    self.dateBetweenLabel.text = [NSString stringWithFormat:@"Kies een datum tussen %@ en %@.", [_minDate getStringFromDateWithFormat:@"dd MMMM yyyy"], [_maxDate getStringFromDateWithFormat:@"dd MMMM yyyy"]];
}

- (IBAction)dayButtonTapped:(id)sender {
    [ActionSheetDatePicker showPickerWithTitle:nil
                                datePickerMode:UIDatePickerModeDate
                                  selectedDate:_day ?: [NSDate date]
                                   minimumDate:_minDate
                                   maximumDate:_maxDate
                                     doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                                         self.day = selectedDate;
                                         [self.pickDayButton setTitle:[selectedDate getStringFromDateWithFormat:@"dd MMMM yyyy"] forState:UIControlStateNormal];
                                     } cancelBlock:nil
                                        origin:self.pickDayButton];
}

- (IBAction)hourButtonTapped:(id)sender {
    [ActionSheetDatePicker showPickerWithTitle:nil
                                datePickerMode:UIDatePickerModeTime
                                  selectedDate:_hour ?: [NSDate date]
                                   minimumDate:nil
                                   maximumDate:nil
                                     doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                                         self.hour = selectedDate;
                                         [self.pickHourButton setTitle:[selectedDate getStringFromDateWithFormat:@"HH:mm"] forState:UIControlStateNormal];
                                     } cancelBlock:nil
                                        origin:self.pickDayButton];
}

- (IBAction)planEventButtonTapped:(id)sender {
    if (!_hour || !_day) {
        [[[UIAlertView alloc] initWithTitle:@"Opgepast" message:@"Gelieve een dag en uur aan te duiden aub." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    NSString *fullDate = [NSString stringWithFormat:@"%@ %@", self.pickDayButton.titleLabel.text, self.pickHourButton.titleLabel.text];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setLocale:[NSLocale currentLocale]];
    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    if ([_planAnEventDelegate respondsToSelector:@selector(dateSelected:)]){
        [_planAnEventDelegate dateSelected:[dateFormat dateFromString:fullDate]];
    }
}

@end
