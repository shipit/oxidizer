//
//  OXMessage.m
//  OxidizerBenchmark
//
//  Created by Sumeet Parmar on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OXMessage.h"

@implementation OXMessage

@synthesize params;

+ (OXMessage *) handshakeMessage {
    OXMessage *message = [[OXMessage alloc] init];
    
    NSArray *connectionList = [NSArray arrayWithObjects:@"long-polling", @"callback-polling", nil];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"/meta/handshake" forKey:@"channel"];
    [params setObject:@"1.0"             forKey:@"version"];
    [params setObject:connectionList     forKey:@"supportedConnectionTypes"];
    
    message.params = params;
    
    return message;
}

+ (OXMessage *) connectWithClientId:(NSString *) clientId withTransport:(NSString *) transport {
    OXMessage *message = [[OXMessage alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"/meta/connect" forKey:@"channel"];
    [params setObject:@"1.0"           forKey:@"version"];
    [params setObject:clientId         forKey:@"clientId"];
    
    message.params = params;
    
    return message;
}

@end
