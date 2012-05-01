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

@interface Oxidizer : NSObject {
    @private
    NSString *_url;
}

@property (readonly,atomic) NSString *url;

- (void) connectWithUrl:(NSString *) url 
                success:(void (^)(Oxidizer *oxidizer)) successBlock 
                failure:(void (^) (Oxidizer *oxidizer)) failureBlock;

- (void) disconnect:(void (^)(Oxidizer *oxidizer)) block 
            failure:(void (^) (Oxidizer *oxidizer)) block;

- (void) handshake:(void (^)(Oxidizer *oxidizer)) block 
           failure:(void (^) (Oxidizer *oxidizer)) block;

- (void) subscribeToChannel:(NSString *) channelName
                    success:(void (^)(OXChannel *channel)) block 
                    failure:(void (^) (OXChannel *channel)) block;

@end
