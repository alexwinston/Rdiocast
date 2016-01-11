//
//  NSString+MD5.m
//  PyrcastFM
//
//  Created by Alex Winston on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+MD5.h"


@implementation NSString (md5)

- (NSString *)md5 
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
	CC_MD5([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
	NSMutableString *ms = [NSMutableString string];
	for (i=0;i<CC_MD5_DIGEST_LENGTH;i++) {
		[ms appendFormat: @"%02x", (int)(digest[i])];
	}
	return [[ms copy] autorelease]; 
}

@end
