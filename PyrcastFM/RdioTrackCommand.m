//
//  RdioTrackCommand.m
//  PyrcastFM
//
//  Created by Alex Winston on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RdioTrackCommand.h"


@implementation RdioTrackCommand

@synthesize playerName;
@synthesize playbackToken;
@synthesize trackKey;

- (void)executeWithConsumer:(OAConsumer *)consumer token:(OAToken *)token {
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.rdio.com/1/"]
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    [request setParameters:[NSArray arrayWithObjects:
                            [OARequestParameter requestParameterWithName:@"playerName" value:playerName],
                            [OARequestParameter requestParameterWithName:@"playbackToken" value:playbackToken],
                            [OARequestParameter requestParameterWithName:@"key" value:trackKey],
                            [OARequestParameter requestParameterWithName:@"type" value:@"mp4-high"],
                            [OARequestParameter requestParameterWithName:@"manualPlay" value:@"true"],
                            [OARequestParameter requestParameterWithName:@"method" value:@"getPlaybackInfo"], nil]];
    
    [self fetchDataWithRequest:request];
}

- (void)dealloc
{
    [playerName release];
    [playbackToken release];
    [trackKey release];
    [super dealloc];
}

@end
