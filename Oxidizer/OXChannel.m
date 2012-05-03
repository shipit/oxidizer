//
//  OXChannel.m
//  Oxidizer
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 TopHatter. All rights reserved.
//

#import "OXChannel.h"

@implementation OXChannel

@synthesize subscription = _subscription;
@synthesize delegate;

+ (OXChannel *)channelWithParams:(NSDictionary *)params {
    OXChannel *channel = [[OXChannel alloc] init];
    channel->_subscription = [params objectForKey:@"subscription"];
    
    return channel;
}

@end
