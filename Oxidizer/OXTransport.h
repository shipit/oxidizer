//
//  OXTransport.h
//  OxidizerBenchmark
//
//  Created by Sumeet Parmar on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OXTransport <NSObject>

@required
- (void) connectToUrl:(NSString *) url;
- (void) disconnect;

- (void) send:(NSDictionary *) params 
      success:(void (^) (id JSON)) successBlock
      failure:(void (^) (NSError *error)) failureBlock;

- (void) setReceiveBlock:(void (^) (id JSON)) block;

@end
