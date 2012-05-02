//
//  Oxidizer.h
//  Oxidizer
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 TopHatter. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Ref: http://svn.cometd.com/trunk/bayeux/bayeux.html#toc_16
-------------++------------+-------------+------------+------------
State/Event  || handshake  | Timeout     | Successful | Disconnect
||  request   |             |   connect  |  request
||   sent     |             |  response  |   sent
-------------++------------+-------------+----------- +------------
UNCONNECTED  || CONNECTING | UNCONNECTED |            |
CONNECTING   ||            | UNCONNECTED | CONNECTED  | UNCONNECTED
CONNECTED    ||            | UNCONNECTED |            | UNCONNECTED
-------------++------------+-------------+------------+------------
*/

typedef enum {
    Init,
    Connecting,
    Connected,
    Disconnecting,
    Disconnected,
    Unconnected
} OXState;

@class OXChannel;
@class AFHTTPClient;

@interface Oxidizer : NSObject {
    @private
    NSString *_url;
    OXState _state;
    AFHTTPClient *_httpClient;
}

@property (readonly,nonatomic) NSString *url;
@property (readonly,atomic) OXState state;

+ (id) initWithUrl:(NSString *) url;

- (void) handshakeWithSuccess:(void (^)(Oxidizer *oxidizer)) successBlock 
                      failure:(void (^) (Oxidizer *oxidizer)) failureBlock;

- (void) connectWithSuccess:(void (^)(Oxidizer *oxidizer)) successBlock 
                    failure:(void (^) (Oxidizer *oxidizer)) failureBlock;

- (void) disconnectWithSuccess:(void (^)(Oxidizer *oxidizer)) successBlock 
                       failure:(void (^) (Oxidizer *oxidizer)) failureBlock;

- (void) subscribeToChannel:(NSString *) channelName
                    success:(void (^)(OXChannel *channel)) successBlock 
                    failure:(void (^) (OXChannel *channel)) failureBlock;

@end
