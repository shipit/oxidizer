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
@synthesize delegate;

+ (id) connector {
    static Oxidizer *connector;
    
    if (connector == nil) {
        connector = [[Oxidizer alloc] init];
    }
    
    return connector;
}

- (void) configOptions {
    _state = Disconnected;
    _httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:_url]];
    [_httpClient setParameterEncoding:AFJSONParameterEncoding]; 
}

- (void) handshakeWithUrl:(NSString *) url {
    _url = url;
    [self configOptions];
    
    _state = Connecting;
        
    NSArray *connectionList = [NSArray arrayWithObjects:@"long-polling", @"callback-polling", nil];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"1" forKey:@"id"];
    [params setObject:@"/meta/handshake" forKey:@"channel"];
    [params setObject:@"1.0"             forKey:@"version"];
    [params setObject:connectionList     forKey:@"supportedConnectionTypes"];
    
    NSURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"" parameters:params];
    
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

- (void) connect {
    
}

- (void) disconnect {
    
}

- (void) subscribeToChannel:(NSString *) channelName {
    
}

- (NSString *) description {
    return [NSString stringWithFormat:@"{url=%@,state=%d}", _url, _state];
}

@end
