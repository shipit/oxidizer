//
//  OXMessage.m
//  OxidizerBenchmark
//
//  Created by Sumeet Parmar on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OXMessage.h"
#import "Oxidizer.h"

@implementation OXMessage

@synthesize params = _params;
@synthesize channelName = _channelName;
@synthesize clientId = _clientId;
@synthesize version = _version;
@synthesize transport = _transport;
@synthesize data = _data;
@synthesize subscription = _subscription;

- (id) init {
    self = [super init];
    _version = @"1.0";
    _clientId = [Oxidizer connector].clientId;
    
    return self;
}

- (id) initWithParams:(NSDictionary *)params {
    self = [self init];
    
    if (params) {
        _params = params;
    }
    
    return self;
}

- (NSDictionary *) params {
    NSMutableDictionary *dict;
    
    if (_params) {
        dict = [NSMutableDictionary dictionaryWithDictionary:_params];
    } else {
        dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    [dict setObject:_channelName forKey:@"channel"];
    [dict setObject:_version forKey:@"version"];
    
    if (_clientId) {
        [dict setObject:_clientId forKey:@"clientId"];
    }
    
    if (_transport) {
        [dict setObject:_transport forKey:@"connectionType"];
    }
    
    if (_subscription) {
        [dict setObject:_subscription forKey:@"subscription"];
    }
    
    return dict;
}

+ (OXMessage *) handshakeMessage {
    NSArray *connectionList = [NSArray arrayWithObjects:@"long-polling", @"callback-polling", @"websocket", nil];
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:connectionList     forKey:@"supportedConnectionTypes"];
    
    OXMessage *message = [[[OXMessage alloc] initWithParams:params] autorelease];
    
    message->_channelName = @"/meta/handshake";
        
    return message;
}

+ (OXMessage *) connectWithTransport:(NSString *) transport {
    OXMessage *message = [[[OXMessage alloc] init] autorelease];
    message->_channelName = @"/meta/connect";
    message->_transport = transport;

    return message;
}

+ (OXMessage *) subscribeToChannel:(NSString *) channelName {
    OXMessage *message = [[[OXMessage alloc] init] autorelease];
    message->_channelName = @"/meta/subscribe";
    message->_subscription = channelName;
    
    return message;    
}

+ (OXMessage *) messageForChannel:(NSString *) channelName withData:(NSDictionary *) data {
    OXMessage *message = [[[OXMessage alloc] init] autorelease];
    message->_channelName = channelName;
    message->_data = data;
        
    return message;     
}

@end
