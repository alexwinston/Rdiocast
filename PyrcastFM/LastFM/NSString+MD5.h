//
//  NSString+MD5.h
//  PyrcastFM
//
//  Created by Alex Winston on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>


@interface NSString (MD5)

- (NSString *)md5;

@end
