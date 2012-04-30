//
//  OxidizerTests.m
//  OxidizerTests
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Oxidizer.h"
#import "OxidizerTests.h"

@implementation OxidizerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void) testConnect {
    Oxidizer *ox = [Oxidizer connectWithUrl:@"http://asdf/connect"];
    NSLog(@"ox = %@", ox);
    [ox release];
}

- (void)testHandshake {
    NSLog(@"testHandshake") ;
}

@end