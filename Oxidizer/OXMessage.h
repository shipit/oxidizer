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
    NSString *_clientId;
    NSString *_channelName;
    NSString *_version;
    NSObject *_data;
    NSString *_transport;
    NSString *_subscription;
    NSDictionary *_params;
}

@property (retain,nonatomic,readonly) NSDictionary *params;
@property (retain,nonatomic,readonly) NSString *channelName;
@property (retain,nonatomic,readonly) NSString *clientId;
@property (retain,nonatomic,readonly) NSString *version;
@property (retain,nonatomic,readonly) NSString *transport;
@property (retain,nonatomic,readonly) NSObject *data;
@property (retain,nonatomic,readonly) NSString *subscription;

+ (OXMessage *) handshakeMessage;
+ (OXMessage *) connectWithTransport:(NSString *) transport;
+ (OXMessage *) subscribeToChannel:(NSString *) channelName;
+ (OXMessage *) messageForChannel:(NSString *) channelName withData:(NSDictionary *) data;

- (id) initWithParams:(NSDictionary *) params;

@end
