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
#import "OXChannel.h"

@implementation Oxidizer

@synthesize url = _url;
@synthesize state = _state;
@synthesize delegate;
@synthesize clientId = _clientId;

#pragma mark - Construction

+ (Oxidizer *) connector {
    static Oxidizer *connector;
    
    if (connector == nil) {
        connector = [[Oxidizer alloc] init];
    }
    
    return connector;
}

- (id) init {
    self = [super init];
    _channelMap = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) configOptions {
    _state = Disconnected;
    _httpClient = [[AFHTTPClient clientWithBaseURL:[NSURL URLWithString:_url]] retain];
    [_httpClient setParameterEncoding:AFJSONParameterEncoding]; 
}

#pragma mark - Bayeux Protocol

#pragma mark - Handshake

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

#pragma mark - Connect

- (void) connect {
    OXMessage *message = [OXMessage connectWithTransport:@"long-polling"];
    NSLog(@"connect message = %@", message.params);
    
    NSURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"" parameters:message.params];
    [message release];
    
    AFJSONRequestOperation *jsonRequest = 
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        [self processConnectSuccessResponse:JSON];
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"ERROR = %@", JSON);
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
        NSLog(@"** SETTING UP CONNECT ADVICE **");
        NSInteger interval = [[adviceParams objectForKey:@"timeout"] intValue] / 1000;
        [self setupPollerWithInterval:interval];
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

#pragma  mark - Subscribe

- (void) subscribeToChannel:(NSString *) channelName 
                    success:(void (^)(OXChannel *channel)) successBlock
                    failure:(void (^)(Oxidizer *oxidizer)) failureBlock {
    
    OXMessage *message = [OXMessage subscribeToChannel:channelName];
    NSURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"" parameters:message.params];
    [message release];
    
    AFJSONRequestOperation *jsonRequest = 
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        [self processSubscribeSuccessResponse:JSON success:successBlock failure:failureBlock];
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"ERROR = %@", error);
                                                        _state = Disconnected;
                                                    }];
    
    [_httpClient enqueueHTTPRequestOperation:jsonRequest];     
}

- (void) processSubscribeSuccessResponse:(id) JSON
                                 success:(void (^)(OXChannel *channel)) successBlock
                                 failure:(void (^)(Oxidizer *oxidizer)) failureBlock {
    NSDictionary *dict = [JSON objectAtIndex:0];
    BOOL successful = [[dict objectForKey:@"successful"] boolValue];

    if (successful) {
        OXChannel *channel = [OXChannel channelWithParams:dict];
        [_channelMap setObject:channel forKey:channel.subscription];
        
        if (successBlock != nil) {
            successBlock(channel);
        }
    } else {
        if (failureBlock) {
            failureBlock(self);
        }
    }
}

#pragma mark - Long poller

dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer) {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    
    return timer;
}

- (void) setupPollerWithInterval:(NSInteger) interval {
    NSLog(@"setupPollerWithInterval:%d", interval);
    
    _pollTimer = CreateDispatchTimer(interval * NSEC_PER_SEC,
                                      1ull * NSEC_PER_SEC, 
                                     dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), 
                                     ^{ [self doPollAction]; });
}

- (void) doPollAction {
    NSLog(@"timer:doPollAction");
    [self connect];
}

#pragma mark - Publish message 

- (void) publishMessageToChannel:(NSString *) channelName withData:(NSDictionary *) data {
    OXMessage *message = [OXMessage messageForChannel:channelName withData:data];
    NSURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"" parameters:message.params];
    [message release];
    
    AFJSONRequestOperation *jsonRequest = 
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        NSLog(@"SUCCESS = %@", JSON);
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"ERROR = %@", error);
                                                    }];
    
    [_httpClient enqueueHTTPRequestOperation:jsonRequest];      
}

#pragma mark - NSObject delegate

- (NSString *) description {
    return [NSString stringWithFormat:@"{url=%@,state=%d}", _url, _state];
}

#pragma mark - Memory management

- (void) dealloc {
    [_httpClient release];
    [super dealloc];
}

@end
