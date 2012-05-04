//
//  OXMessage.h
//  OxidizerBenchmark
//
//  Created by Sumeet Parmar on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OXMessage : NSObject {
    
}

@property (retain,nonatomic) NSDictionary *params;

+ (OXMessage *) handshakeMessage;
+ (OXMessage *) connectWithTransport:(NSString *) transport;
+ (OXMessage *) subscribeToChannel:(NSString *) channelName;
+ (OXMessage *) messageForChannel:(NSString *) channelName withData:(NSDictionary *) data;

@end
