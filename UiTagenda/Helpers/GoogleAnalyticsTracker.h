//
//  GoogleAnalyticsTracker.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 8/10/15.
//  Copyright © 2015 Cultuurnet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIEcommerceProduct.h"
#import "GAIEcommerceProductAction.h"
#import "GAIEcommercePromotion.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import "GAITrackedViewController.h"
#import "GAITracker.h"

static NSString *googleTrackerID = @"";

@interface GoogleAnalyticsTracker : NSObject

+ (id)sharedInstance;
- (void)trackGoogleAnalyticsWithValue:(NSString *)value;

@end
