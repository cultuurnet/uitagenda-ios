//
//  UiTSearchWhenViewController.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 6/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UiTSearchWhenDelegate <NSObject>

-(void)setWhenValue:(NSString *)value;

@end

@interface UiTSearchWhenViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

-(id)initWithValue:(NSString *)value;

@property (nonatomic, weak) id<UiTSearchWhenDelegate> delegate;

@end