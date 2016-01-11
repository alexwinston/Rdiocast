//
//  FMSession.m
//  PyrcastFM
//
//  Created by Alex Winston on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FMSession.h"


@implementation FMSession
@synthesize name;
@synthesize key;
@synthesize isSubscriber;

#pragma mark -
#pragma mark FMSession lifecycle methods

- (FMSession *)initWithDictionary:(NSDictionary *)dictionary {
    if (!(self = [super init]))
		return nil;
    
    name = [dictionary objectForKey:@"name"];
    key = [dictionary objectForKey:@"key"];
    isSubscriber = [[dictionary objectForKey:@"name"] isEqual:@"1"] ? YES : NO;
    
    return self;
}

- (void)dealloc {
    [name release];
    [key release];
    [super dealloc];
}
@end
