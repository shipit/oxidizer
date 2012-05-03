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
    
}

@property (readonly,nonatomic) NSString *name;
@property (assign,nonatomic) id <OXChannelDelegate> delegate;

- (void) publish:(NSString *)message;
- (void) unsubscribe;

@end

@protocol OXChannelDelegate <NSObject>

- (void) didReceiveMessageFromChannel:(OXChannel *) channel;
- (void) didUnsubscribe;

@end