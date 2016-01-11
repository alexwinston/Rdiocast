//
//  FMStation.h
//  PyrcastFM
//
//  Created by Alex Winston on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FMStation : NSObject {
    NSString *name;
    NSString *url;
}
@property (readonly, retain) NSString *name;
@property (readonly, retain) NSString *url;
- (FMStation *)initWithDictionary:(NSDictionary *)dictionary;
@end
