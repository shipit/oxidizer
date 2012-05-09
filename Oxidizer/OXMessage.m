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

@synthesize params;
@synthesize channelName = _channelName;

+ (OXMessage *) handshakeMessage {
    OXMessage *message = [[[OXMessage alloc] init] autorelease];
    message->_channelName = @"/meta/handshake";
    
    NSArray *connectionList = [NSArray arrayWithObjects:@"long-polling", @"callback-polling", @"websocket", nil];
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:message.channelName forKey:@"channel"];
    [params setObject:@"1.0"             forKey:@"version"];
    [params setObject:connectionList     forKey:@"supportedConnectionTypes"];
    
    message.params = params;
    
    return message;
}

+ (OXMessage *) connectWithTransport:(NSString *) transport {
    OXMessage *message = [[[OXMessage alloc] init] autorelease];
    message->_channelName = @"/meta/connect";
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:message.channelName              forKey:@"channel"];
    [params setObject:@"1.0"                        forKey:@"version"];
    [params setObject:transport                     forKey:@"connectionType"];
    [params setObject:[Oxidizer connector].clientId forKey:@"clientId"];
    
    message.params = params;
    
    return message;
}

+ (OXMessage *) subscribeToChannel:(NSString *) channelName {
    OXMessage *message = [[[OXMessage alloc] init] autorelease];
    message->_channelName = @"/meta/subscribe";
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:message.channelName            forKey:@"channel"];
    [params setObject:@"1.0"                        forKey:@"version"];
    [params setObject:[Oxidizer connector].clientId forKey:@"clientId"];
    [params setObject:channelName                   forKey:@"subscription"];    
    
    message.params = params;
    
    return message;    
}

+ (OXMessage *) messageForChannel:(NSString *) channelName withData:(NSDictionary *) data {
    OXMessage *message = [[[OXMessage alloc] init] autorelease];
    message->_channelName = channelName;
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:channelName                   forKey:@"channel"];
    [params setObject:@"1.0"                        forKey:@"version"];
    [params setObject:[Oxidizer connector].clientId forKey:@"clientId"];
    [params setObject:data                          forKey:@"data"];
    
    message.params = params;
    
    return message;     
}

@end
