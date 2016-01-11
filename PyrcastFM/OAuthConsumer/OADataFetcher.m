//
//  OADataFetcher.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 11/5/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "CJSONDeserializer.h"
#import "OADataFetcher.h"


@implementation OADataFetcher

- (OADataFetcher *)initWithDelegate:(id)aDelegate selector:(SEL)aSelector {
    self = [super init];
    if (self) {
        _delegate = aDelegate;
        _selector = aSelector;
    }
    
    return self;
}

- (void)fetchDataWithRequest:(OAMutableURLRequest *)aRequest 
					delegate:(id)aDelegate 
		   didFinishSelector:(SEL)finishSelector 
			 didFailSelector:(SEL)failSelector 
{
    request = aRequest;
    delegate = aDelegate;
    didFinishSelector = finishSelector;
    didFailSelector = failSelector;
    
    [request prepare];
    
    responseData = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
	
    if (response == nil || responseData == nil || error != nil) {
        OAServiceTicket *ticket= [[OAServiceTicket alloc] initWithRequest:request
                                                                 response:response
                                                               didSucceed:NO];
        [delegate performSelector:didFailSelector
                       withObject:ticket
                       withObject:error];
    } else {
        OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
                                                                  response:response
                                                                didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];
        [delegate performSelector:didFinishSelector
                       withObject:ticket
                       withObject:responseData];
    }   
}

- (void)fetchDataWithRequest:(OAMutableURLRequest *)aRequest
{
    [self fetchDataWithRequest:aRequest
                      delegate:self
             didFinishSelector:@selector(requestForServiceTicket:didFinishWithData:)
               didFailSelector:@selector(requestForServiceTicket:didFailWithError:)];  
}

- (void) requestForServiceTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"requestForServiceTicket:didFinishWithData:");
    
    // Deserialize the data
	NSDictionary *dataJson = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil];
    
    if ([_delegate respondsToSelector:_selector]) {
        error = nil;
        if ([@"error" isEqualToString:[dataJson valueForKey:@"status"]])
            error = [NSError errorWithDomain:@"RdioErrorDomain" code:0 userInfo:dataJson]; // TODO fix userInfo
        
        [_delegate performSelector:_selector
                        withObject:error ? nil : [dataJson valueForKey:@"result"]
                        withObject:error];
    }
}

- (void) requestForServiceTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)anError
{
    NSLog(@"requestForServiceTicket:didFailWithError:%@", [anError description]);
    
    if ([_delegate respondsToSelector:_selector]) {
        [_delegate performSelector:_selector
                        withObject:nil
                        withObject:anError];
    }
}

@end
