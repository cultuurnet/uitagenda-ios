//
//  UiTAPIClient.m
//  UiTagenda
//
//  Created by Jarno Verreyt on 4/12/13.
//  Copyright (c) 2013 Cultuurnet. All rights reserved.
//

#import "UiTAPIClient.h"

@interface UiTAPIClient ()
@end

@implementation UiTAPIClient

+(UiTAPIClient *)sharedClient {
    static UiTAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:BASE_URL];
        _sharedClient = [[UiTAPIClient alloc] initWithBaseURL:baseURL consumerKey:CONSUMERKEY consumerSecret:CONSUMERSECRET];
    });
    
    return _sharedClient;
}

-(NSURLSessionDataTask *)getPath:(NSString *)path getParameters:(NSDictionary *)parameters completion:(void (^)(NSArray *results, NSError *error))completion {
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
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