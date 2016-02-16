//
//  UiTEvent.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 11/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const kEventTimeStampFullDate;
extern NSString * const kEventTimeStampFullDateString;

@interface UiTEvent : NSObject

@property (strong, nonatomic) NSDictionary *bookingPeriod;
@property (nonatomic) NSNumber *ageFrom;

@property (strong, nonatomic) NSMutableDictionary *contactInfo;
@property (strong, nonatomic) NSMutableDictionary *contactReservationInfo;

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *streetAndNr;
@property (strong, nonatomic) NSString *zipcode;
@property (strong, nonatomic) NSString *city;

@property (strong, nonatomic) NSString *createdBy;
@property (strong, nonatomic) NSNumber *creationDate;

@property (strong, nonatomic) NSMutableArray *keywords;
@property (strong, nonatomic) NSMutableArray *categories;

@property (strong, nonatomic) NSString *locationValue;

@property (nonatomic) BOOL datePassed;

@property (strong, nonatomic) NSString *calendarSummary;
@property (strong, nonatomic) NSString *longDescription;
@property (strong, nonatomic) NSMutableArray *mediaInfo;

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *organiser;
@property (strong, nonatomic) NSString *place;
@property (strong, nonatomic) NSString *shortDescription;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *priceDescription;
@property (strong, nonatomic) NSArray *performers;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *cdbid;

@property (nonatomic, assign) BOOL isPermanent;
@property (nonatomic, strong) NSDate *dateFrom;
@property (nonatomic, strong) NSDate *dateTo;

@property (nonatomic, strong) NSMutableArray *possibleDates;

@property (nonatomic, assign) BOOL noPossibleDate;

-(id)initWithDictionary:(NSDictionary *)event;

@property (nonatomic) float latCoordinate;
@property (nonatomic) float lonCoordinate;

- (NSString *)getDistanceToEventFromLocation:(CLLocation *)location;

@end