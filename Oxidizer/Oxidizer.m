//
//  Oxidizer.m
//  Oxidizer
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 TopHatter. All rights reserved.
//

#import "Oxidizer.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

@implementation Oxidizer

@synthesize url = _url;
@synthesize state = _state;

+ (id) initWithUrl:(NSString *)url {
    Oxidizer *ox = [[Oxidizer alloc] init];
    ox->_url = url;
    ox->_httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:ox->_url]];
    return ox;
}

- (id) init {
    self = [super init];
    _state = Disconnected;
    [_httpClient setParameterEncoding:AFJSONParameterEncoding];
    return self;
}

- (void) handshakeWithSuccess:(void (^)(Oxidizer *))successBlock 
                    failure:(void (^)(Oxidizer *))failureBlock {
    _state = Connecting;
        
    NSArray *connectionList = [NSArray arrayWithObjects:@"long-polling", @"callback-polling", nil];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"1" forKey:@"id"];
    [params setObject:@"/meta/handshake" forKey:@"channel"];
    [params setObject:@"1.0"             forKey:@"version"];
    [params setObject:connectionList     forKey:@"supportedConnectionTypes"];
    
    NSURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"/" parameters:params];
    NSLog(@"REQUEST = %@", request);
    
    AFJSONRequestOperation *jsonRequest = 
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        NSLog(@"SUCCESS response = %@", JSON);
                                                        _state = Connected;
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"ERROR = %@", error);
                                                        _state = Disconnected;
                                                    }];
    [_httpClient enqueueHTTPRequestOperation:jsonRequest];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"{url=%@,state=%d}", _url, _state];
}

@end
