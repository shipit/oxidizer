//
//  Oxidizer.h
//  Oxidizer
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Init,
    Connecting,
    Connected,
    Disconnecting,
    Disconnected    
} OXState;

@interface Oxidizer : NSObject {
    @private
    NSString *_url;
}

@property (readonly,atomic) NSString *url;

+ (id) connectWithUrl:(NSString *) url;

@end
