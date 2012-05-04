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
@protocol OxidizerDelegate;

@interface Oxidizer : NSObject {
    @private
    NSString *_url;
    OXState _state;
    AFHTTPClient *_httpClient;
    
    NSString *_clientId;
    NSMutableDictionary *_channelMap;
    dispatch_source_t _pollTimer;
    int _nextMessageId;
}

@property (readonly,nonatomic) NSString *url;
@property (readonly,atomic) OXState state;
@property (assign,nonatomic) id<OxidizerDelegate> delegate;
@property (readonly,nonatomic) NSString *clientId;

+ (Oxidizer *) connector;

- (void) handshakeWithUrl:(NSString *)url;
- (void) connect;
- (void) disconnect;
- (void) subscribeToChannel:(NSString *) channelName 
                    success:(void (^)(OXChannel *channel)) successBlock
                    failure:(void (^)(Oxidizer *oxidizer)) failureBlock;
- (void) publishMessageToChannel:(NSString *) channelName withData:(NSDictionary *) data;

- (void) configOptions;

@end

@protocol OxidizerDelegate <NSObject>

- (void) didHandshakeForConnector:(Oxidizer *)connector withResult:(BOOL)result withParams:(NSDictionary *)params;
- (void) didConnectForConnector:(Oxidizer *)connector withResult:(BOOL)result;
- (void) didDisconnectForConnector:(Oxidizer *)connector withResult:(BOOL)result;
- (void) didSubscribeToChannel:(OXChannel *)channel withResult:(BOOL)result;

@end
