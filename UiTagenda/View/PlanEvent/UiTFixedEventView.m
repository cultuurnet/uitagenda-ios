//
//  UiTFixedEventView.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 16/01/16.
//  Copyright © 2016 Cultuurnet. All rights reserved.
//

#import "UiTFixedEventView.h"
#import "UiTEvent.h"

@interface UiTFixedEventView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *chooseADateTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *planEventButton;

@property (nonatomic, strong) NSDate *currentSelectedDate;

@end

@implementation UiTFixedEventView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.chooseADateTitleLabel.font = [UIFont customBoldFontWithSize:20];
    self.planEventButton.titleLabel.font = [UIFont customRegularFontWithSize:20];
    [self.tableView reloadData];
}

- (IBAction)planEventButtonTapped:(id)sender {
    if (_currentSelectedDate) {
        if ([_planAnEventDelegate respondsToSelector:@selector(dateSelected:)]){
            [_planAnEventDelegate dateSelected:_currentSelectedDate];
        }
    }
}

#pragma mark - UITableView DataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.possibleDates count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell  *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont customRegularFontWithSize:18];
    }
    
    if (_possibleDates[indexPath.row][kEventTimeStampFullDate] == _currentSelectedDate) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = _possibleDates[indexPath.row][kEventTimeStampFullDateString];
    
    return cell;

}

#pragma mark - UITableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _currentSelectedDate = _possibleDates[indexPath.row][kEventTimeStampFullDate];
    [self.tableView reloadData];
}

@end
