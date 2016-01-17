//
//  UiTTimeSpanEventView.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 16/01/16.
//  Copyright © 2016 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UiTPlanAnEventDelegate.h"

@interface UiTTimeSpanEventView : UIView

@property (nonatomic, weak) id <UiTPlanAnEventDelegate> planAnEventDelegate;

@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;

@end
