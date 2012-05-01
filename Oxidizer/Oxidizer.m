//
//  Oxidizer.m
//  Oxidizer
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 TopHatter. All rights reserved.
//

#import "Oxidizer.h"

@implementation Oxidizer

@synthesize url = _url;

- (void) connectWithUrl:(NSString *) url 
                success:(void (^)(Oxidizer *oxidizer)) successBlock 
                failure:(void (^) (Oxidizer *oxidizer)) failureBlock {
    
    _url = url;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"url=%@", _url];
}

@end
