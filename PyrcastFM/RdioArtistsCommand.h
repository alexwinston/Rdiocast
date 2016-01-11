//
//  RdioArtistsCommand.h
//  PyrcastFM
//
//  Created by Alex Winston on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OADataFetcher.h"


@interface RdioArtistsCommand : OADataFetcher {
@private
    
}
@property (readwrite, retain) NSString *name;
- (void)executeWithConsumer:(OAConsumer *)consumer token:(OAToken *)token;
@end
