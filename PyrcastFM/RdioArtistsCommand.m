//
//  RdioArtistsCommand.m
//  PyrcastFM
//
//  Created by Alex Winston on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RdioArtistsCommand.h"


@implementation RdioArtistsCommand
@synthesize name;

- (void)executeWithConsumer:(OAConsumer *)consumer token:(OAToken *)token {
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.rdio.com/1/"]
                                                                    consumer:consumer
                                                                       token:token
                                                                       realm:nil
                                                           signatureProvider:nil] autorelease];
    [request setHTTPMethod:@"POST"];
    [request setParameters:[NSArray arrayWithObjects:
                            [OARequestParameter requestParameterWithName:@"method" value:@"search"],
                            [OARequestParameter requestParameterWithName:@"query" value:name],
                            [OARequestParameter requestParameterWithName:@"types" value:@"Artist, Album"], nil]];
    
    [self fetchDataWithRequest:request];
}

- (void)dealloc
{
    [name release];
    [super dealloc];
}

@end
