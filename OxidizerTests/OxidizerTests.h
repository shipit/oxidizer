//
//  OxidizerTests.h
//  OxidizerTests
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 TopHatter. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class Oxidizer;

@interface OxidizerTests : SenTestCase {
    @private
    NSString *_testUrl;
    Oxidizer *_candidate;
    
}

- (void) nop;

@end
