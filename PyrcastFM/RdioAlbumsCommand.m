//
//  RdioAlbumsCommand.m
//  PyrcastFM
//
//  Created by Alex Winston on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CJSONDeserializer.h"
#import "RdioAlbumsCommand.h"


@implementation RdioAlbumsCommand
@synthesize artistKey;

- (void)executeWithConsumer:(OAConsumer *)consumer token:(OAToken *)token {
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.rdio.com/1/"]
                                                                    consumer:consumer
                                                                       token:token
                                                                       realm:nil
                                                           signatureProvider:nil] autorelease];
    [request setHTTPMethod:@"POST"];
    [request setParameters:[NSArray arrayWithObjects:
                            [OARequestParameter requestParameterWithName:@"method" value:@"getAlbumsForArtist"],
                            [OARequestParameter requestParameterWithName:@"artist" value:artistKey],
                            [OARequestParameter requestParameterWithName:@"extras" value:@"trackKeys"], nil]];
    
    [self fetchDataWithRequest:request];
}

- (void)dealloc
{
    [artistKey release];
    [super dealloc];
}

@end
