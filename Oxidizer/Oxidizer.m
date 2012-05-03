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
#import "OXMessage.h"

@implementation Oxidizer

@synthesize url = _url;
@synthesize state = _state;
@synthesize delegate;

#pragma mark - Construction

+ (id) connector {
    static Oxidizer *connector;
    
    if (connector == nil) {
        connector = [[Oxidizer alloc] init];
    }
    
    return connector;
}

- (void) configOptions {
    _state = Disconnected;
    _httpClient = [[AFHTTPClient clientWithBaseURL:[NSURL URLWithString:_url]] retain];
    [_httpClient setParameterEncoding:AFJSONParameterEncoding]; 
}

#pragma mark - Bayeux Protocol

- (void) handshakeWithUrl:(NSString *) url {
    _url = url;
    [self configOptions];

    _state = Connecting;
    
    NSURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"" parameters:[OXMessage handshakeMessage].params];
    
    AFJSONRequestOperation *jsonRequest = 
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        [self processHandshakeSuccessResponse:JSON];
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"ERROR = %@", error);
                                                        _state = Disconnected;
                                                    }];
    
    [_httpClient enqueueHTTPRequestOperation:jsonRequest];
}

- (void) processHandshakeSuccessResponse:(id) JSON {
    NSDictionary *dict = [JSON objectAtIndex:0];
    BOOL successful = [[dict objectForKey:@"successful"] boolValue];
    
    if (successful) {
        _clientId = [[dict objectForKey:@"clientId"] retain];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), 
                       ^ { [self connect]; });
    } else {
        _state = Unconnected;
    }
    
    if (self.delegate != nil) {
        [delegate didHandshakeForConnector:self withResult:successful withParams:dict];
    }
}

- (void) connect {
    OXMessage *message = [OXMessage connectWithClientId:_clientId withTransport:@"long-polling"];
    
    NSURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"" parameters:message.params];
    
    AFJSONRequestOperation *jsonRequest = 
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        [self processConnectSuccessResponse:JSON];
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"ERROR = %@", error);
                                                        _state = Disconnected;
                                                    }];
    
    [_httpClient enqueueHTTPRequestOperation:jsonRequest];    
}

- (void) processConnectSuccessResponse:(id) JSON {
    _state = Connected;
    
    NSDictionary *dict = [JSON objectAtIndex:0];
    BOOL successful = [[dict objectForKey:@"successful"] boolValue];
    
    if (successful) {
        [self processConnectAdvice:dict];
    }
    
    if (self.delegate != nil) {
        [delegate didConnectForConnector:self withResult:successful];
    }
}

- (void) processConnectAdvice:(NSDictionary *) dict {
    NSDictionary *adviceParams = [dict objectForKey:@"advice"];
    
    if (adviceParams != nil) {
        /*
         advice =         {
         interval = 0;
         reconnect = retry;
         timeout = 30000;
         };
         */
    }
}

- (void) disconnect {
    
}

- (void) subscribeToChannel:(NSString *) channelName {
    
}

- (NSString *) description {
    return [NSString stringWithFormat:@"{url=%@,state=%d}", _url, _state];
}

#pragma mark - Memory management

- (void) dealloc {
    [_httpClient release];
    [super dealloc];
}

@end
