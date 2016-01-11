//
//  RdioAlbumsCommand.h
//  PyrcastFM
//
//  Created by Alex Winston on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OADataFetcher.h"


@interface RdioAlbumsCommand : OADataFetcher {
@private
}
@property (readwrite, retain) NSString *artistKey;
- (void)executeWithConsumer:(OAConsumer *)consumer token:(OAToken *)token;
@end
