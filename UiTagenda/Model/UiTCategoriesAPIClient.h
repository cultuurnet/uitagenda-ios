//
//  UiTCategoriesAPIClient.h
//  UiTagenda
//
//  Created by Jarno Verreyt on 17/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface UiTCategoriesAPIClient : AFHTTPSessionManager

+(UiTCategoriesAPIClient *)sharedClient;

-(NSURLSessionDataTask *)getPath:(NSString *)path getParameters:(NSDictionary *)parameters completion:(void (^)(NSArray *results, NSError *error))completion;

@end