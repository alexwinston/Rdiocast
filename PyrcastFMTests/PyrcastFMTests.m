//
//  PyrcastFMTests.m
//  PyrcastFMTests
//
//  Created by Alex Winston on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PyrcastFMTests.h"

#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "LastFM.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"


@implementation PyrcastFMTests

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testGetToken {
    __block BOOL tokenReceived = NO;
    
    LastFM *lastfm = [[[LastFM alloc] init] autorelease];
    [lastfm getToken:^(NSString *token, NSError *error) {
        if (!error)
            STAssertNotNil(token, @"Unauthorized request tokens shouldn't be nil");
        tokenReceived = YES;
    }];
    
    while (!tokenReceived) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
    }
}

- (void)testGetSession {
    __block BOOL sessionReceived = NO;
    
    LastFM *lastfm = [[[LastFM alloc] init] autorelease];
    [lastfm getToken:^(NSString *token, NSError *error){
        if (!error)
            STAssertNotNil(token, @"Unauthorized request tokens shouldn't be nil");
        
        [lastfm getSession:token usingBlock:^(FMSession *session, NSError *error) {
            NSLog(@"%@", [error description]);
            STAssertNotNil(error, @"This token should not be authorized");
            STAssertTrue([error code] == 14, @"The error code for unauthorized tokens should be 14");
            sessionReceived = YES;
        }];
    }];
    
    while (!sessionReceived) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
    }
}

// Authenticated token:0a0d71e78e370f3fb86a2a0948f467af session:cc55c136b20f8ffca529bfe9a1a4c43e

- (void)testArtistSearch {
    __block BOOL artistsReceived = NO;
    
    LastFM *lastfm = [[[LastFM alloc] init] autorelease];
    [lastfm artistSearch:@"Mumford & Sons" usingBlock:^(NSArray *artists, NSError *error) {
        STAssertNil(error, @"artistSearch shouldn't return an error");
        artistsReceived = YES;
    }];
    
    while (!artistsReceived) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
    }
}

- (void)testRadioSearch {
    __block BOOL stationsReceived = NO;

    LastFM *lastfm = [[[LastFM alloc] init] autorelease];
    // Adele, Joe Purday, Mumford & Sons, Grey's Anatomy
    [lastfm radioSearch:@"Grey's Anatomy" usingBlock:^(FMStation *station, NSError *error) {
        STAssertNil(error, @"readioSearch shouldn't return an error");
        STAssertTrue([station.name isEqual:@"Grey's Anatomy Radio"], @"The station name isn't equal");
        stationsReceived = YES;
    }];
    
    while (!stationsReceived) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
    }
}

@end
