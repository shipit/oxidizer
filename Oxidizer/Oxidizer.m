//
//  Oxidizer.m
//  Oxidizer
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Oxidizer.h"

@implementation Oxidizer

@synthesize url = _url;

+ (id) connectWithUrl:(NSString *) url {
    Oxidizer *ox = [[Oxidizer alloc] init];
    ox->_url = url;
    
    return ox;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"url=%@", _url];
}

@end
