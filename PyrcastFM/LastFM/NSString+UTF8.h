//
//  NSString+UTF8.h
//  PyrcastFM
//
//  Created by Alex Winston on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (UTF8)

- (NSString *)decode;
- (NSString *)encode;
- (NSString *)escape;

@end
