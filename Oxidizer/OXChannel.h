//
//  OXChannel.h
//  Oxidizer
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 TopHatter. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OXChannelDelegate;

@interface OXChannel : NSObject {
    @private
    NSString *_subscription;
}

@property (readonly,nonatomic) NSString *subscription;
@property (assign,nonatomic) id <OXChannelDelegate> delegate;

+ (OXChannel *) channelWithParams:(NSDictionary *) params;

- (void) publish:(NSString *)message;
- (void) unsubscribe;

@end

@protocol OXChannelDelegate <NSObject>

- (void) didReceiveMessage:(id) JSON fromChannel:(OXChannel *) channel;
- (void) didUnsubscribe;

@end