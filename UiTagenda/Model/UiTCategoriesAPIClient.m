//
//  UiTCategoriesAPIClient.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 17/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTCategoriesAPIClient.h"

@implementation UiTCategoriesAPIClient

+(UiTCategoriesAPIClient *)sharedClient {
    static UiTCategoriesAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:CATEGORIES_URL];
        _sharedClient = [[UiTCategoriesAPIClient alloc] initWithBaseURL:baseURL];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    return _sharedClient;
}

-(NSURLSessionDataTask *)getPath:(NSString *)path getParameters:(NSDictionary *)parameters completion:(void (^)(NSArray *results, NSError *error))completion {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionDataTask *task = [self GET:path
                                parameters:parameters
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                       if (httpResponse.statusCode == 200) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(responseObject, nil);
                                           });
                                       }
                                       else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, nil);
                                           });
                                       }
                                   } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
//                                       NSLog(@"%@", error);
                                       if (httpResponse.statusCode == 404) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, error);
                                           });
                                       }
                                       else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               completion(nil, error);
                                           });
                                       }
                                   }];
    
    return task;
}

@end