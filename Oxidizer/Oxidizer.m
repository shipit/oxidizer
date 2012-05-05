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
    _nextMessageId = 0;
    return self;
}

- (void) configOptions {
    _state = Disconnected;
    _httpClient = [[AFHTTPClient clientWithBaseURL:[NSURL URLWithString:_url]] retain];
    [_httpClient setParameterEncoding:AFJSONParameterEncoding]; 
}

#pragma mark - Bayeux Protocol

#pragma mark - Handshake

- (void) sendMessage:(OXMessage *) message 
             success:(void (^)(id JSON)) successBlock 
             failure:(void (^) (NSHTTPURLResponse *response, NSError *error)) failureBlock {
    _nextMessageId++;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:message.params];
    [params setObject:[NSNumber numberWithInt:_nextMessageId] forKey:@"id"];
    
    NSURLRequest *request = [_httpClient requestWithMethod:@"POST" path:@"" parameters:params];
    
    AFJSONRequestOperation *jsonRequest = 
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        [self processMessages:JSON];
                                                        
                                                        if (successBlock) {
                                                            successBlock([self getResponseForMessage:message fromJSON:JSON]);
                                                        }
                                                        
                                                        [self processAdvice:JSON];
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        NSLog(@"ERROR, request = %@, response = %@, error = %@, error = %@", request, response, error, JSON);
                                                        if (failureBlock) {
                                                            failureBlock(response, error);
                                                        }
                                                    }];
    
    [_httpClient enqueueHTTPRequestOperation:jsonRequest];
}

- (id) getResponseForMessage:(OXMessage *) message fromJSON:(id) JSON {
    id response = nil;
    
    for (int i = 0; i < [JSON count]; i++) {
        id element = [JSON objectAtIndex:i];
        NSString *channelName = [element objectForKey:@"channel"];
        
        if (channelName == nil) {
            continue;
        }
        
        if ([channelName isEqualToString:message.channelName]) {
            response = element;
            break;
        }
    }
    
    return response;
}

- (void) processMessages:(id) JSON {
    for (int i = 0; i < [JSON count]; i++) {
        id element = [JSON objectAtIndex:i];
        NSLog(@"element = %@", element);
        
        NSString *channelName = [element objectForKey:@"channel"];
        
        if (channelName == nil) {
            continue;
        }
        
        OXChannel *channel = [_channelMap objectForKey:channelName];
        
        if (channel != nil) {
            if (channel.delegate != nil) {
                [channel.delegate didReceiveMessage:element fromChannel:channel];
            }
        } else {
            //meta channel
            NSLog(@"got channel = %@", channelName);
        }
    }
}

- (void) handshakeWithUrl:(NSString *) url {
    _url = url;
    [self configOptions];

    _state = Connecting;
    
    [self sendMessage:[OXMessage handshakeMessage] 
              success:^ (id JSON) { [self processHandshakeSuccessResponse:JSON]; }  
              failure:nil];
}

- (void) processHandshakeSuccessResponse:(id) JSON {
    NSDictionary *dict = JSON;
    BOOL successful = [[dict objectForKey:@"successful"] boolValue];
    
    if (successful) {
        _clientId = [[dict objectForKey:@"clientId"] retain];
        NSArray *transports = [dict objectForKey:@"supportedConnectionTypes"];
        if ([transports containsObject:@"long-polling"]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), 
                           ^ { [self connect]; });
        } else {
            NSLog(@"ERROR long-polling not available - QUITTING!!!");
        }
    } else {
        _state = Unconnected;
    }
    
    if (self.delegate != nil) {
        [delegate didHandshakeForConnector:self withResult:successful withParams:dict];
    }
}

#pragma mark - Connect

- (void) connect {
    [self sendMessage:[OXMessage connectWithTransport:@"long-polling"] 
              success:^(id JSON) { [self processConnectSuccessResponse:JSON]; } 
              failure:nil];   
}

- (void) processConnectSuccessResponse:(id) JSON {
    _state = Connected;
    
    NSLog(@"connect, JSON = %@", JSON);
    BOOL successful = [[JSON objectForKey:@"successful"] boolValue];
    
    if (self.delegate != nil) {
        [delegate didConnectForConnector:self withResult:successful];
    }
}

/*
 advice =         {
 interval = 0;
 reconnect = retry;
 timeout = 30000;
 };
 */
- (void) processAdvice:(id) JSON {
    
    for (int i = 0; i < [JSON count]; i++) {
        id element = [JSON objectAtIndex:i];
        NSDictionary *adviceParams = [element valueForKey:@"advice"];
        
        if (adviceParams) {
            NSLog(@"** SETTING UP CONNECT ADVICE **");
            
            NSString *reconnect = [adviceParams objectForKey:@"reconnect"];
            
            if ([@"retry" isEqualToString:reconnect]) {
                NSInteger interval = [[adviceParams objectForKey:@"timeout"] intValue] / 1000;
                
                if (interval == -1) {
                    if (_pollTimer) {
                        dispatch_source_cancel(_pollTimer);
                    }
                } else {
                    [self setupPollerWithInterval:interval];
                }

            }
        }
    }
}

- (void) disconnect {
    
}

#pragma  mark - Subscribe

- (void) subscribeToChannel:(NSString *) channelName 
                    success:(void (^)(OXChannel *channel)) successBlock
                    failure:(void (^)(Oxidizer *oxidizer)) failureBlock {
    
    [self sendMessage:[OXMessage subscribeToChannel:channelName] 
              success:^(id JSON) { [self processSubscribeSuccessResponse:JSON success:successBlock failure:failureBlock]; }
              failure:nil];
}

- (void) processSubscribeSuccessResponse:(id) JSON
                                 success:(void (^)(OXChannel *channel)) successBlock
                                 failure:(void (^)(Oxidizer *oxidizer)) failureBlock {
    NSDictionary *dict = JSON;
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
    [self sendMessage:[OXMessage messageForChannel:channelName withData:data] 
              success:nil 
              failure:nil];
}

#pragma mark - NSObject delegate

- (NSString *) description {
    return [NSString stringWithFormat:@"{url=%@,state=%d}", _url, _state];
}

#pragma mark - Memory management

- (void) dealloc {
    if (_pollTimer) {
        dispatch_source_cancel(_pollTimer);
    }
    
    [_httpClient release];
    [super dealloc];
}

@end
