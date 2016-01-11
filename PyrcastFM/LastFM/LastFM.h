//
//  LastFM.h
//  PyrcastFM
//
//  Created by Alex Winston on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMSession.h"
#import "FMStation.h"


extern NSString * const LastFMErrorDomain;
extern int const LastFMUnknownErrorCode;

@interface LastFM : NSObject {
    NSString *_apiKey;
    NSString *_apiSecret;
}
// Auth methods
- (void)getToken:(void (^)(NSString *token, NSError *error))block;
- (void)getSession:(NSString *)token usingBlock:(void (^)(FMSession *session, NSError *error))block;
// Artist methods
- (void)artistSearch:(NSString *)name usingBlock:(void (^)(NSArray *artists, NSError *error))block;
- (void)artistSearch:(NSString *)name withLimit:(int)limit forPage:(int)page usingBlock:(void (^)(NSArray *artists, NSError *error))block;
// Radio methods
- (void)radioSearch:(NSString *)name usingBlock:(void (^)(FMStation *station, NSError *error))block;
@end
