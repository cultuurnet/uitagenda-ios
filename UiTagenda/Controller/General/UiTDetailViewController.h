//
//  UiTDetailViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TTTAttributedLabel/TTTAttributedLabel.h"
#import "UiTDetailContainerViewController.h"

#import "UiTEvent.h"


@interface UiTDetailViewController : UiTDetailContainerViewController <UIScrollViewDelegate, UIWebViewDelegate, TTTAttributedLabelDelegate, UIWebViewDelegate>
@property (strong, nonatomic) UiTEvent *event;
@property (strong, nonatomic) NSArray *eventsArray;
@end