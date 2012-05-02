//
//  OxidizerTests.m
//  OxidizerTests
//
//  Created by Sumeet Parmar on 4/30/12.
//  Copyright (c) 2012 TopHatter. All rights reserved.
//

#import "Oxidizer.h"
#import "OxidizerTests.h"
#import "AFNetworking.h"

@implementation OxidizerTests

- (void)setUp
{
    [super setUp];
    _testUrl = @"http://local.tophatter";
    _candidate = [Oxidizer initWithUrl:_testUrl];
    NSLog(@"ox = %@", _candidate);
}

- (void)tearDown
{
    // Tear-down code here.
    [_candidate release];
    [super tearDown];
}

//- (void) testHandshake {
//    [_candidate handshakeWithSuccess:nil failure:nil];
//}

- (void) testGet {
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://apple.com"]];
    [client getPath:@"/" parameters:nil 
                            success:^(AFHTTPRequestOperation *operation , id responseObject) {
                                NSLog(@"SUCCESS response = %@", responseObject);
                            }
     
                            failure:^(AFHTTPRequestOperation *operation , NSError *error) {
                                NSLog(@"ERROR = %@", error);
                            }];
    
    while (YES) {
        
    }
}

- (void) nop {
    NSLog(@"NOP");
}

@end
