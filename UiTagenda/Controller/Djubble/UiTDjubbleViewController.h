//
//  UiTDjubbleViewController.h
//  UiTagenda
//
//  Created by Robbe Vandecasteele on 04/01/16.
//  Copyright © 2016 Cultuurnet. All rights reserved.
//

#import "UiTBaseViewController.h"
#import "UiTEvent.h"

typedef NS_ENUM(NSUInteger, UiTTypeEvent) {
    UiTTypeEventOngoing = 0,
    UiTTypeEventTimeSpan,
    UiTTypeEventFixed
};

@interface UiTDjubbleViewController : UIViewController

@property (nonatomic, strong) UiTEvent *selectedEvent;
@property (nonatomic) UiTTypeEvent typeEvent;

@end