//
//  OXLongPollTransport.m
//  OxidizerBenchmark
//
//  Created by Sumeet Parmar on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OXLongPollTransport.h"

@implementation OXLongPollTransport

- (id) init {
    self = [super init];
    return self;
}

#pragma mark - OXTransport protocol

- (void) connectToUrl:(NSString *) url {
    if (!_httpClient) {
        NSLog(@"initialize AFHTTPClient!!!!");
        _httpClient = [[AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]] retain];
        [_httpClient setParameterEncoding:AFJSONParameterEncoding]; 
    }
}

- (void) disconnect {
    
}

- (void) send:(NSDictionary *) params 
      success:(void (^) (id JSON)) successBlock
      failure:(void (^) (NSError *error)) failureBlock {
    
    NSURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"" parameters:params];
    
    AFJSONRequestOperation *jsonRequest = 
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        NSLog(@"AF:success response, request = %@", request);
                                                        
                                                        if (successBlock) {
                                                            successBlock(JSON);
                                                        }
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"ERROR, request = %@, response = %@, error = %@, error = %@", request, response, error, JSON);
                                                        if (failureBlock) {
                                                            failureBlock(error);
                                                        }
                                                    }];
    
    NSLog(@"AF:enqueue http request = %@", jsonRequest);
    [_httpClient enqueueHTTPRequestOperation:jsonRequest];    
}

- (void) setReceiveBlock:(void (^) (id JSON)) block {
    
}

#pragma mark - Memory management
- (void) dealloc {
    if (_httpClient) {
        [_httpClient release];
    }
    
    [super dealloc];
}

@end
