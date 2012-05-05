//
//  OXMessage.h
//  OxidizerBenchmark
//
//  Created by Sumeet Parmar on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OXMessage : NSObject {
    @private
    NSString *_channelName;
}

@property (retain,nonatomic) NSDictionary *params;
@property (retain,nonatomic,readonly) NSString *channelName;

+ (OXMessage *) handshakeMessage;
+ (OXMessage *) connectWithTransport:(NSString *) transport;
+ (OXMessage *) subscribeToChannel:(NSString *) channelName;
+ (OXMessage *) messageForChannel:(NSString *) channelName withData:(NSDictionary *) data;

@end
