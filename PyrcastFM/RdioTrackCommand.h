//
//  RdioTrackCommand.h
//  PyrcastFM
//
//  Created by Alex Winston on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OADataFetcher.h"


@interface RdioTrackCommand : OADataFetcher {
@private
    
}
@property (readwrite, retain) NSString *playerName;
@property (readwrite, retain) NSString *playbackToken;
@property (readwrite, retain) NSString *trackKey;
- (void)executeWithConsumer:(OAConsumer *)consumer token:(OAToken *)token;
@end
