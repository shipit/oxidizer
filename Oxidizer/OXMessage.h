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
+ (OXMessage *) connectWithClientId:(NSString *) clientId withTransport:(NSString *) transport;

@end