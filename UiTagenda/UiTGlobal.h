//
//  UiTGlobal.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 5/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASE_URL @"http://www.uitid.be/uitid/rest/"
#define CATEGORIES_URL @"http://test.taxonomy.uitdatabank.be/api/domain/"

#define CONSUMERKEY @""
#define CONSUMERSECRET @""

#define NEWRELICTOKEN @""

#define SLIDEMENUCOLOR UIColorFromHex(0x323232)
#define BACKGROUNDCOLOR UIColorFromHex(0xecebeb)

// UiTDetailCell
#define REDCOLOR UIColorFromHex(0xd4222d)
#define DATECOLOR UIColorFromHex(0x323232)
#define LOCATIONCOLOR UIColorFromHex(0xc6c6c6)
#define CITYCOLOR UIColorFromHex(0x323232)


// DETAILVIEW

#define TITLECOLOR UIColorFromHex(0x323232)
#define BOXCALENDARADDRESS UIColorFromHex(0xf1f1f1)


#define EXTRAINFOCELLCOLOR UIColorFromHex(0xB7B7B7)
#define PLACECELLCOLOR UIColorFromHex(0x7E7E7E)
#define EXTRASVIEWCELLCOLOR UIColorFromHex(0xFAFAFA)

#define BUTTONCOLOR UIColorFromHex(0xf12b10)

#define CELLBACKGROUNDCOLOR UIColorFromHex(0xE1E1E2)
#define TABLEVIEWCOLOR UIColorFromHex(0xecebeb)

#define tableViewHeight HEIGHT(self.view) - HEIGHT(self.tabBarController.tabBar) - HEIGHT(self.navigationController.navigationBar) - [UIApplication sharedApplication].statusBarFrame.size.height

#define RADIUS 10.0

#define amountOfRows 15

// DESIGN (COLORS)



#define DATEANDLOCATIONCOLOR UIColorFromHex(0x323232)





@protocol UiTGlobal <NSObject>

@end