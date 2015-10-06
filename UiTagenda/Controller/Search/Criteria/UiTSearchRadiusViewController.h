//
//  UiTSearchRadiusViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 6/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UiTSearchRadiusDelegate <NSObject>
@required
- (void) setRadiusValue:(NSString *)value;
@end

@interface UiTSearchRadiusViewController : UIViewController

-(id)initWithValue:(NSString *)value;

@property (nonatomic, weak) id<UiTSearchRadiusDelegate> delegate;
@property (strong, nonatomic) NSString *value;
@end