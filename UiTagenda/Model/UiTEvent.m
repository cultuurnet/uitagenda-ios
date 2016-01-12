//
//  UiTEvent.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 11/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTEvent.h"

#define IMAGEWIDTH 165
#define IMAGEHEIGHT 190

@implementation UiTEvent

- (id)initWithDictionary:(NSDictionary *)event {
    self = [super init];
    if (self) {
        self.organiser = @"";
        _contactInfo = [[NSMutableDictionary alloc] init];
        _contactReservationInfo = [[NSMutableDictionary alloc] init];
        _categories = [[NSMutableArray alloc] init];
        
        _latCoordinate = 0;
        _lonCoordinate = 0;
        
        NSMutableArray *contactInfoURL = [[NSMutableArray alloc] init];
        NSMutableArray *contactInfoPhone = [[NSMutableArray alloc ] init];
        NSMutableArray *contactInfoMail = [[NSMutableArray alloc] init];
        
        NSMutableArray *contactInfoReservationURL = [[NSMutableArray alloc] init];
        NSMutableArray *contactInfoReservationPhone = [[NSMutableArray alloc ] init];
        NSMutableArray *contactInfoReservationMail = [[NSMutableArray alloc] init];
        
        self.bookingPeriod = (NSDictionary *)[event valueForKeyPath:@"event.bookingperiod"];
        if ([event valueForKeyPath:@"event.agefrom"] != [NSNull null]) {
            self.ageFrom = [event valueForKeyPath:@"event.agefrom"];
        }
        
        NSArray *arrayWithContactInfo = (NSArray *)[event valueForKeyPath:@"event.contactinfo.addressAndMailAndPhone"];
        
        for (NSArray *contactInfo in arrayWithContactInfo) {
            if ([contactInfo valueForKey:@"address"]) {
                _address = [NSString stringWithFormat:@"%@ %@, %@ %@",
                            [contactInfo valueForKeyPath:@"address.physical.street.value"],
                            [contactInfo valueForKeyPath:@"address.physical.housenr"] != [NSNull null] ? [contactInfo valueForKeyPath:@"address.physical.housenr"] : @"",
                            [contactInfo valueForKeyPath:@"address.physical.zipcode"],
                            [contactInfo valueForKeyPath:@"address.physical.city.value"]];
                _streetAndNr = [NSString stringWithFormat:@"%@ %@",
                                [contactInfo valueForKeyPath:@"address.physical.street.value"],
                                [contactInfo valueForKeyPath:@"address.physical.housenr"]];
                _zipcode = [contactInfo valueForKeyPath:@"address.physical.zipcode"];
                _city = [contactInfo valueForKeyPath:@"address.physical.city.value"];
                
                if ([contactInfo valueForKeyPath:@"address.physical.gis.ycoordinate"] != [NSNull null]) {
                    _latCoordinate = [[contactInfo valueForKeyPath:@"address.physical.gis.ycoordinate"] floatValue];
                } else {
                    _latCoordinate = 0;
                }
                
                if ([contactInfo valueForKeyPath:@"address.physical.gis.xcoordinate"] != [NSNull null]) {
                    _lonCoordinate = [[contactInfo valueForKeyPath:@"address.physical.gis.xcoordinate"] floatValue];
                } else {
                    _lonCoordinate = 0;
                }
                
//                _latCoordinate = [[contactInfo valueForKeyPath:@"address.physical.gis.ycoordinate"] floatValue];
//                _lonCoordinate = [[contactInfo valueForKeyPath:@"address.physical.gis.xcoordinate"] floatValue];
            } else {
                if ([contactInfo valueForKey:@"phone"]) {
                    if ([contactInfo valueForKeyPath:@"phone.reservation"] != [NSNull null]) {
                        if ([[contactInfo valueForKeyPath:@"phone.reservation"] boolValue]) {
                            [contactInfoReservationPhone addObject:[contactInfo valueForKeyPath:@"phone.value"]];
                        }
                    } else {
                        [contactInfoPhone addObject:[contactInfo valueForKeyPath:@"phone.value"]];
                    }
                }
                else if ([contactInfo valueForKey:@"mail"]) {
                    if ([contactInfo valueForKeyPath:@"mail.reservation"] != [NSNull null]) {
                        if ([[contactInfo valueForKeyPath:@"mail.reservation"] boolValue]) {
                            [contactInfoReservationMail addObject:[contactInfo valueForKeyPath:@"mail.value"]];
                        }
                    } else {
                        [contactInfoMail addObject:[contactInfo valueForKeyPath:@"mail.value"]];
                    }
                } else if ([contactInfo valueForKey:@"url"]) {
                    if ([contactInfo valueForKeyPath:@"url.reservation"] != [NSNull null]) {
                        if ([[contactInfo valueForKeyPath:@"url.reservation"] boolValue]) {
                            [contactInfoReservationURL addObject:[contactInfo valueForKeyPath:@"url.value"]];
                        }
                    } else {
                        [contactInfoURL addObject:[contactInfo valueForKeyPath:@"url.value"]];
                    }
                } else {
                    
                }
            }
        }
        
        if ([contactInfoPhone count] > 0) [_contactInfo setObject:contactInfoPhone forKey:@"phone"];
        if ([contactInfoMail count] > 0) [_contactInfo setObject:contactInfoMail forKey:@"mail"];
        if ([contactInfoURL count] > 0) [_contactInfo setObject:contactInfoURL forKey:@"url"];
        if ([contactInfoReservationPhone count] > 0) [_contactReservationInfo setObject:contactInfoReservationPhone forKey:@"phone"];
        if ([contactInfoReservationURL count] > 0) [_contactReservationInfo setObject:contactInfoReservationURL forKey:@"url"];
        if ([contactInfoReservationMail count] > 0) [_contactReservationInfo setObject:contactInfoReservationMail forKey:@"mail"];
        
        self.createdBy = [event valueForKeyPath:@"event.createdby"];
        self.creationDate = (NSNumber *)[event valueForKeyPath:@"event.creationdate"];
        if ([event valueForKeyPath:@"event.organiser"] != [NSNull null]) {
            self.organiser = [event valueForKeyPath:@"event.organiser.label.value"];
        }
        
        if ([event valueForKeyPath:@"event.categories.category"] != [NSNull null]) {
            for (NSArray *category in [event valueForKeyPath:@"event.categories.category"]) {
                if ([[category valueForKey:@"type"] isEqualToString:@"eventtype"]) {
                    [_categories addObject:[category valueForKey:@"value"]];
                }
            }
        }
        
        _keywords = [[NSMutableArray alloc] init];
        
        if ([event valueForKeyPath:@"event.keywords"] != [NSNull null]) {
            _keywords = (NSMutableArray *)[[event valueForKeyPath:@"event.keywords"] componentsSeparatedByString:@";"];
        }
        
        if ([event valueForKeyPath:@"event.location.label.value"] != [NSNull null]) {
            _locationValue = [event valueForKeyPath:@"event.location.label.value"];
        }
        
        self.calendarSummary = [self checkIfStringExists:[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"calendarsummary"]];
        
        if ([self.calendarSummary hasPrefix:@"\n"] && [self.calendarSummary length] > 1){
            self.calendarSummary = [self.calendarSummary substringFromIndex:1];
        }
        
        self.longDescription = [self checkIfStringExists:[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"longdescription"]];
        
        _mediaInfo = [[NSMutableArray alloc] init];
        if ([[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"media"] valueForKey:@"file"] != [NSNull null]) {
            NSArray *arrayWithMedia = [(NSArray *)[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"media"] valueForKey:@"file"];
            
            for (NSArray *mediaInfo in arrayWithMedia) {
                if ([[mediaInfo valueForKey:@"mediatype"] isEqualToString:@"webresource"]) {
                    [_mediaInfo addObject:[mediaInfo valueForKeyPath:@"hlink"]];
                } else if ([[mediaInfo valueForKey:@"mediatype"] isEqualToString:@"facebook"]) {
                    [_mediaInfo addObject:[mediaInfo valueForKeyPath:@"hlink"]];
                } else {
                    
                }
            }
        }
        
        self.price = [NSString stringWithFormat:@"%@",[self checkIfStringExists:[[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"price"] valueForKey:@"pricevalue"]]];
        self.priceDescription = [self checkIfStringExists:[[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"price"] valueForKey:@"pricedescription"]];
        
        self.title = [self checkIfStringExists:[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"title"]];
        self.place = [self createPlaceString:event];
        
        self.shortDescription = [self checkIfStringExists:[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"shortdescription"]];
        
        _performers = [[NSArray alloc] init];
        
        if ([[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"performers"] valueForKey:@"performer"] != [NSNull null]) {
            _performers = (NSArray *)[[[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"performers"] valueForKey:@"performer"];
        }
        
        self.cdbid = [self checkIfStringExists:[event valueForKeyPath:@"event.cdbid"]];
        self.imageURL = [self getImageURL:event];
        
        self.datePassed = [self isDatePassed:[event valueForKeyPath:@"event.availableto"]];
    }
    return self;
}

-(NSString *)checkIfStringExists:(NSString *)value {
    if (value != (id)[NSNull null]) {
        return value;
    }
    return @"";
}

-(BOOL)isDatePassed:(NSNumber *)availableTo {
    if (availableTo != nil) {
        NSTimeInterval interval = [availableTo doubleValue] / 1000;
        
        NSDate *dateEvent = [NSDate dateWithTimeIntervalSince1970:interval];
        
        if ([dateEvent compare:[NSDate date]] == NSOrderedAscending) {
            return YES;
        }
    }
    return NO;
}

-(NSString *)createPlaceString:(NSDictionary *)event {
    NSString *locationValue = [self checkIfStringExists:[event valueForKeyPath:@"event.location.label.value"]];
    NSString *cityValue = [self checkIfStringExists:[event valueForKeyPath:@"event.location.address.physical.city.value"]];
    
    if (![locationValue isEqualToString:@""] && ![cityValue isEqualToString:@""]) {
        return [NSString stringWithFormat:@"%@, %@", locationValue, cityValue];
    }
    else if (![locationValue isEqualToString:@""]) {
        return locationValue;
    }
    else if (![cityValue isEqualToString:@""]) {
        return cityValue;
    }
    else {
        return @"";
    }
}

-(NSURL *)getImageURL:(NSDictionary *)event {
    NSDictionary *mediaDict = [[event valueForKeyPath:@"event.eventdetails.eventdetail"][0] valueForKey:@"media"];
    
    if (mediaDict != (id)[NSNull null]) {
        NSDictionary *mediaFileDict = [mediaDict valueForKey:@"file"];
        for (NSDictionary *dict in mediaFileDict) {
            if ([[dict valueForKey:@"mediatype"] isEqualToString:@"photo"]) {
                
                NSString *imageUrl;
                
                if ([[dict valueForKey:@"hlink"] hasPrefix:@"//"]) {
                    imageUrl = [NSString stringWithFormat:@"http:%@", [dict valueForKey:@"hlink"]];
                }
                else {
                    imageUrl = [dict valueForKey:@"hlink"];
                }
                
                return [NSURL URLWithString:[NSString stringWithFormat:@"%@?width=%i&height=%i&crop=auto", imageUrl, IMAGEWIDTH, IMAGEHEIGHT]];
            }
        }
    }
    return nil;
}

- (NSString *)getDistanceToEventFromLocation:(CLLocation *)location {
    if (location) {
        NSString *distance = @"";
        CLLocation *restoLocation = [[CLLocation alloc] initWithLatitude:self.latCoordinate
                                                               longitude:self.lonCoordinate];
        
        int distanceInMeters = (int)[restoLocation distanceFromLocation:location];
        
        if (distanceInMeters < 100000 && distanceInMeters > 0) {
            if (distanceInMeters < 1000) {
                distance = [NSString stringWithFormat:@"%dm", distanceInMeters];
            }  else {
                distance = [NSString stringWithFormat:@"%.2fkm", floor(((float)distanceInMeters / 1000) * 100)/100];
            }
        }
        
        return [NSString stringWithFormat:@"(%@)", distance];
    }
    return @"";
}

@end