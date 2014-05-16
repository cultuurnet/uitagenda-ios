//
//  UiTAPIClient.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "BDBOAuth1Manager/BDBOAuth1SessionManager.h"

@interface UiTAPIClient : BDBOAuth1SessionManager

+(UiTAPIClient *)sharedClient;

-(NSURLSessionDataTask *)getPath:(NSString *)path getParameters:(NSDictionary *)parameters completion:(void (^)(NSArray *results, NSError *error))completion;

@end