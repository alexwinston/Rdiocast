//
//  FMStation.m
//  PyrcastFM
//
//  Created by Alex Winston on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FMStation.h"


@implementation FMStation
@synthesize name;
@synthesize url;

#pragma mark -
#pragma mark FMStation lifecycle methods

- (FMStation *)initWithDictionary:(NSDictionary *)dictionary {
    if (!(self = [super init]))
		return nil;
    
    name = [dictionary valueForKeyPath:@"stations.station.name"];
    url = [dictionary valueForKeyPath:@"stations.station.url"];

    return self;
}

- (void)dealloc {
    [name release];
    [url release];
    [super dealloc];
}

@end
