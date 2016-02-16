//
//  UiTFixedEventView.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 16/01/16.
//  Copyright © 2016 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UiTPlanAnEventDelegate.h"

@interface UiTFixedEventView : UIView

@property (nonatomic, weak) id <UiTPlanAnEventDelegate> planAnEventDelegate;

@property (nonatomic, strong) NSArray *possibleDates;

@end
