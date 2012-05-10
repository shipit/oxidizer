//
//  OXLongPollTransport.h
//  OxidizerBenchmark
//
//  Created by Sumeet Parmar on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXTransport.h"
#import "AFNetworking.h"

@interface OXLongPollTransport : NSObject <OXTransport> {
    @private
    AFHTTPClient *_httpClient;
}

@end
