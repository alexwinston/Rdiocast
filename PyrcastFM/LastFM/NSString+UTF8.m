//
//  NSString+UTF8.m
//  PyrcastFM
//
//  Created by Alex Winston on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+UTF8.h"


@implementation NSString (UTF8)

- (NSString *)decode {
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    return [result autorelease];
}
- (NSString *)encode 
{
    NSString *encoded = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                            (CFStringRef)self,
                                                                            NULL,
                                                                            (CFStringRef)@"!*'();:@&+=$,/?%#[]",
                                                                            kCFStringEncodingUTF8);
    return [encoded autorelease];
}

- (NSString *)escape 
{
    
    NSString *escaped = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                            (CFStringRef)[self stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                                                            NULL,
                                                                            (CFStringRef)@"!*'();:@&=$,/?#[]",
                                                                            kCFStringEncodingUTF8);
    if ([escaped rangeOfString:@"%26"].location != NSNotFound)
        return [[escaped autorelease] encode];
        
    return [escaped autorelease];
}

@end
