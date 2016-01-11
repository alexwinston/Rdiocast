//
//  LastFM.m
//  PyrcastFM
//
//  Created by Alex Winston on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "LastFM.h"
#import "NSString+MD5.h"
#import "NSString+UTF8.h"


@implementation LastFM

#pragma mark -
#pragma mark LastFM constant variables

NSString * const LastFMErrorDomain = @"LastFMErrorDomain";
int const LastFMUnknownErrorCode = -1;

#pragma mark -
#pragma mark LastFM lifecycle methods

- (LastFM *)init {
    if (!(self = [super init]))
		return nil;
    
    // Non-commercial API Account
    // Last.fm API Key is 124266e9b23dd8803372b26e58a4f3f2
    // Last.fm secret is e39aa38c75d84f29b12b785046cac3c2
    _apiKey = [@"124266e9b23dd8803372b26e58a4f3f2" retain];
    _apiSecret = [@"e39aa38c75d84f29b12b785046cac3c2" retain];
    
    return self;
}

- (void)dealloc {
    [_apiKey release];
    [_apiSecret release];
    [super dealloc];
}

#pragma mark -
#pragma mark LastFM private methods

- (ASIHTTPRequest *)_requestWithURL:(NSURL *)url usingBlock:(void (^)(id result, NSError *error))block {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setFailedBlock:^{
        NSError *error = [request error];
        DLog(@"%@", [error description]);
        
        block(nil, error);
    }];
    
    return request;
}

- (BOOL)_isError:(NSDictionary *)responseJson usingBlock:(void (^)(id result, NSError *error))block {
    if ([responseJson objectForKey:@"error"]) {
        block(nil, [NSError errorWithDomain:LastFMErrorDomain
                                       code:[[responseJson objectForKey:@"error"] integerValue]
                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[responseJson objectForKey:@"message"],NSLocalizedDescriptionKey,nil]]);
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark LastFM public methods

- (void)getToken:(void (^)(NSString *token, NSError *error))block {
    NSURL *tokenURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?format=json&method=auth.getToken&api_key=%@", _apiKey]];

    __block ASIHTTPRequest *tokenRequest = [self _requestWithURL:tokenURL usingBlock:block];
	[tokenRequest setRequestMethod: @"GET"];
    
    [tokenRequest setCompletionBlock:^{
        // Deserialize the token response
        NSData *tokenResponseData = [tokenRequest responseData];
        NSDictionary *tokenResponseJson = [[CJSONDeserializer deserializer] deserializeAsDictionary:tokenResponseData error:nil];
        DLog(@"%@", [tokenResponseJson description]);
        
        if ([tokenResponseJson objectForKey:@"token"]) {
            block([tokenResponseJson objectForKey:@"token"], nil);
            return;
        }
        
        block(nil, [NSError errorWithDomain:LastFMErrorDomain code:LastFMUnknownErrorCode userInfo:nil]);
    }];
    
    [tokenRequest startAsynchronous];
}

- (void)getSession:(NSString *)token usingBlock:(void (^)(FMSession *session, NSError *error))block {
    NSString *sessionSignature = [NSString stringWithFormat:@"api_key%@methodauth.getSessiontoken%@%@", _apiKey, token, _apiSecret];
    NSURL *sessionURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?format=json&method=auth.getSession&token=%@&api_key=%@&api_sig=%@", token, _apiKey, [sessionSignature md5]]];

    __block ASIHTTPRequest *sessionRequest = [self _requestWithURL:sessionURL usingBlock:block];
	[sessionRequest setRequestMethod: @"GET"];
    
    [sessionRequest setCompletionBlock:^{
        // Deserialize the session response
        NSData *sessionResponseData = [sessionRequest responseData];
        NSDictionary *sessionResponseJson = [[CJSONDeserializer deserializer] deserializeAsDictionary:sessionResponseData error:nil];
        DLog(@"%@", [sessionResponseJson description]);
        
        if ([[sessionResponseJson objectForKey:@"status"] isEqual:@"ok"]) {
            block([[[FMSession alloc] initWithDictionary:sessionResponseJson] autorelease], nil);
            return;
        }
        
        if ([self _isError:sessionResponseJson usingBlock:block])
            return;
        
        block(nil, [NSError errorWithDomain:LastFMErrorDomain code:LastFMUnknownErrorCode userInfo:nil]);
    }];
    
    [sessionRequest startAsynchronous];
}

- (void)artistSearch:(NSString *)name usingBlock:(void (^)(NSArray *artists, NSError *error))block {
    [self artistSearch:name withLimit:50 forPage:1 usingBlock:block];
}

- (void)artistSearch:(NSString *)name withLimit:(int)limit forPage:(int)page usingBlock:(void (^)(NSArray *artists, NSError *error))block {
    NSURL *artistURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?format=json&method=artist.search&artist=%@&api_key=%@", [name encode], _apiKey]];
    
    __block ASIHTTPRequest *artistRequest = [self _requestWithURL:artistURL usingBlock:block];
	[artistRequest setRequestMethod: @"GET"];
    
    [artistRequest setCompletionBlock:^{
        // Deserialize the artist response
        NSData *artistResponseData = [artistRequest responseData];
        NSDictionary *artistResponseJson = [[CJSONDeserializer deserializer] deserializeAsDictionary:artistResponseData error:nil];
        DLog(@"%@", [artistResponseJson description]);
        
        if ([artistResponseJson objectForKey:@"results"]) {
            block([NSArray array], nil);
            return;
        }
        
        if ([self _isError:artistResponseJson usingBlock:block])
            return;
        
        block([NSArray array], nil);
    }];
    
    [artistRequest startAsynchronous];
}

- (void)radioSearch:(NSString *)name usingBlock:(void (^)(FMStation *station, NSError *error))block {
    NSURL *radioURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?format=json&method=radio.search&name=%@&api_key=%@", [name escape], _apiKey]];
    DLog(@"%@", radioURL);
    __block ASIHTTPRequest *radioRequest = [self _requestWithURL:radioURL usingBlock:block];
	[radioRequest setRequestMethod: @"GET"];
    
    [radioRequest setCompletionBlock:^{
        // Deserialize the radio response
        NSData *radioResponseData = [radioRequest responseData];
        NSDictionary *radioResponseJson = [[CJSONDeserializer deserializer] deserializeAsDictionary:radioResponseData error:nil];
        DLog(@"%@", [radioResponseJson description]);
        
        if ([radioResponseJson objectForKey:@"stations"]) {
            block([[FMStation alloc] initWithDictionary:radioResponseJson], nil);
            return;
        }
        
        if ([self _isError:radioResponseJson usingBlock:block])
            return;
        
        block([NSArray array], nil);
    }];
    
    [radioRequest startAsynchronous];
}
                                       
@end
