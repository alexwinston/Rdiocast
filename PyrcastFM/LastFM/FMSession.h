//
//  FMSession.h
//  PyrcastFM
//
//  Created by Alex Winston on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FMSession : NSObject {
    NSString *name;
    NSString *key;
    BOOL isSubscriber;
}
@property (readonly, retain) NSString *name;
@property (readonly, retain) NSString *key;
@property (readonly) BOOL isSubscriber;
- (FMSession *)initWithDictionary:(NSDictionary *)dictionary;
@end
