//
//  PyrcastFMAppDelegate.m
//  PyrcastFM
//
//  Created by Alex Winston on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CJSONDeserializer.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAToken.h"
#import "PyrcastFMAppDelegate.h"
#import "RdioAlbumsCommand.h"
#import "RdioArtistsCommand.h"
#import "RdioTrackCommand.h"


@implementation PyrcastFMAppDelegate
@synthesize window;

- (void)initWithConsumerKey:(NSString *)consumerKey secret:(NSString *)secret {
    _consumer = [[[OAConsumer alloc] initWithKey:consumerKey
                                          secret:secret] retain];
    _rdioConsumer = [[[OAConsumer alloc] initWithKey:@"73b3e93ras372fav48ndxthd"
                                              secret:@"n5pQDneDGv"] retain];
    
    _playerName = [[NSString stringWithFormat:@"android-api-%f", [[NSDate date] timeIntervalSince1970]] retain];
}

- (void)dealloc {
    [_consumer release];
    [_rdioConsumer release];
    [_playerName release];
    [_playbackToken release];
    [super dealloc];
}
                             
- (void)authorizeWithEmail:(NSString *)email password:(NSString *)password
{
    _email = [email retain];
    _password = [password retain];
    
    NSURL *url = [NSURL URLWithString:@"http://api.rdio.com/oauth/request_token"];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:_consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    OARequestParameter *callbackParamter = [OARequestParameter requestParameterWithName:@"oauth_callback" value:@"oob"];
    [request setParameters:[NSArray arrayWithObjects:callbackParamter, nil]];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(authorize:didFailWithError:)];
}

- (void)authorizeWithToken:(NSString *)token {
    _accessToken = [[[OAToken alloc] initWithHTTPResponseBody:token] retain];
    
    // Authorize the current user with the token
    [self currentUser];
}

- (void)searchArtists:(NSString *)name {
    RdioArtistsCommand *rdioArtistsCommand = [[[RdioArtistsCommand alloc] initWithDelegate:self
                                                                                  selector:@selector(rdioDidSearchArtists:error:)] autorelease];
    [rdioArtistsCommand setName:name];
    
    [rdioArtistsCommand executeWithConsumer:_consumer token:_accessToken];
}

- (void)rdioDidSearchArtists:(NSArray *)artists error:(NSError *)error {
    NSLog(@"rdioDidSearchArtists: %@", artists);
    if (_tableViewDataSource)
        [_tableViewDataSource release];
    _tableViewDataSource = [[artists valueForKey:@"results"] retain];
    
    [tableView reloadData];
}

- (void)rdioDidAuthorizeUser:(NSDictionary *)currentUser withAccessToken:(OAToken *)accessToken {
    NSLog(@"rdioDidAuthorizeUser: %@", currentUser);
//    [self searchArtists:@"Mumford & Sons"];
//    [self getAlbumsForArtist:@"r91329"];
//    [self getPlaybackInfo:@"t21667394"];
}

- (void)getAlbumsForArtist:(NSString *)artistKey {
    NSLog(@"getAlbumsForArtist:%@", artistKey);
    RdioAlbumsCommand *rdioAlbumsCommand = [[[RdioAlbumsCommand alloc] initWithDelegate:self
                                                                               selector:@selector(rdioDidGetAlbumsForArtist:error:)] autorelease];
    [rdioAlbumsCommand setArtistKey:artistKey];
    
    [rdioAlbumsCommand executeWithConsumer:_rdioConsumer token:nil];
}

- (void)rdioDidGetAlbumsForArtist:(NSArray *)albums error:(NSError *)error {
    if (error) {
        NSLog(@"rdioDidGetAlbumsForArtist:error: %@", [error description]); return;
    }
    NSLog(@"rdioDidGetAlbumsForArtist: %@", albums);
    
    if (_tableViewDataSource)
        [_tableViewDataSource release];
    _tableViewDataSource = [[NSMutableArray array] retain];
    
    for (NSDictionary *album in albums) {
        if ([[album valueForKey:@"canStream"] boolValue])
            [_tableViewDataSource addObject:album];
    }
    
    [tableView reloadData];
}

- (void)getPlaybackInfo:(NSString *)trackKey {
    RdioTrackCommand *rdioTrackCommand = [[[RdioTrackCommand alloc] initWithDelegate:self
                                                                            selector:@selector(rdioDidGetPlaybackInfo:error:)] autorelease];
    [rdioTrackCommand setPlayerName:_playerName];
    [rdioTrackCommand setPlaybackToken:_playbackToken];
    [rdioTrackCommand setTrackKey:trackKey];
    
    [rdioTrackCommand executeWithConsumer:_rdioConsumer token:nil];
}

- (void)rdioDidGetPlaybackInfo:(NSDictionary *)playbackInfo error:(NSError *)error {
    NSLog(@"rdioDidGetPlaybackInfo:error: %@", playbackInfo);
    
    NSString *surl = [[playbackInfo valueForKeyPath:@"surl"] stringByReplacingOccurrencesOfString:@"30s-96.mp3" withString:@"full-256.mp3"];
    NSLog(@"surl: %@", surl);
    
    NSString *artist = [[playbackInfo valueForKeyPath:@"artist"] stringByReplacingOccurrencesOfString:@"/" withString:@":"];
    NSString *album = [[playbackInfo valueForKeyPath:@"album"] stringByReplacingOccurrencesOfString:@"/" withString:@":"];
    NSString *directory = [[NSString stringWithFormat:@"~/Desktop/%@/%@", artist, album] stringByExpandingTildeInPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    
    [progressTextField setStringValue:[NSString stringWithFormat:@"%@ - %@", [playbackInfo valueForKeyPath:@"trackNum"], [playbackInfo valueForKeyPath:@"name"]]];
    [progressTextField display];
    
    NSString *filePath = [directory stringByAppendingFormat:@"/%@ - %@.mp3", [playbackInfo valueForKeyPath:@"trackNum"], [[playbackInfo valueForKeyPath:@"name"] stringByReplacingOccurrencesOfString:@"/" withString:@":"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *mp3 = [[NSURL URLWithString:surl] resourceDataUsingCache:NO];
        [mp3 writeToFile:filePath atomically:YES];
    }

    [progressTextField setStringValue:@""];
}

-(void)awakeFromNib
{
    NSLog(@"awakeFromNib");
    //[scrollView setBackgroundColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.9]];
    [window setOpaque:NO];
//    CALayer *backgroundLayer = [CALayer layer];
//    [scrollView setLayer:backgroundLayer];
//    [scrollView setWantsLayer:YES];
//    
//    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
//    [blurFilter setDefaults];
//    
//    [scrollView layer].backgroundFilters = [NSArray arrayWithObject:blurFilter];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self initWithConsumerKey:@"nrh8zmfj8erb5vph7yheus29" secret:@"pqfJmdDeVB"];
    
//    [self authorizeWithEmail:@"alex.winston@gmail.com" password:@"rdio9utabeva"];
//    [self authorizeWithToken:@"oauth_token=bh2k7ewu36sfqb58pxppv239w4trxgg6wfkem2zbc6854yep4upfwf5qs3uu854k&oauth_token_secret=zTxNw6NMXSwk"];
//    [self authorizeWithToken:@"oauth_token=cz6nnq26rutn87utuanqz2f8w3vqzh3acz8m5nqxx8b6fvgkmfe2c7xca7n7e2j7&oauth_token_secret=KVRM2KZFuKzY"];
    [self authorizeWithToken:@"oauth_token=t8zvqj8c787dm8duw9qmfhtq4uf8fv6c5nt34ahe377nbxumqeuum3zd2c2qgaj9&oauth_token_secret=3x7eKn85u2ZA"];
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"requestTokenTicket:didFinishWithData:");
    NSString *responseBody = [[NSString alloc] initWithData:data 
                                                   encoding:NSUTF8StringEncoding];
    NSLog(@"%@", responseBody);
    
    _accessToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] retain];
    //[accessToken storeInUserDefaultsWithServiceProviderName:@"rdio" prefix:@"com.alexwinston"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.rdio.com/oauth/authorize_token"]];
    NSLog(@"%@", _accessToken.key);
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:_consumer
                                                                      token:_accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    OARequestParameter *tokenParameter = [OARequestParameter requestParameterWithName:@"request_token" value:_accessToken.key];
    OARequestParameter *emailParamter = [OARequestParameter requestParameterWithName:@"email" value:_email];
    OARequestParameter *passwordParamter = [OARequestParameter requestParameterWithName:@"password" value:_password];
    [request setParameters:[NSArray arrayWithObjects:tokenParameter, emailParamter, passwordParamter, nil]];
    
    [fetcher fetchDataWithRequest:request 
                         delegate:self
                didFinishSelector:@selector(authorizeTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(authorize:didFailWithError:)];
}

- (void) authorizeTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"authorizeTokenTicket:didFinishWithData:");
    NSString *responseBody = [[NSString alloc] initWithData:data 
                                                   encoding:NSUTF8StringEncoding];
    NSLog(@"%@", responseBody);
    [_accessToken updateVerifierWithHTTPResponseBody:responseBody];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://api.rdio.com/oauth/access_token"];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:_consumer
                                                                      token:_accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];

    [fetcher fetchDataWithRequest:request 
                         delegate:self
                didFinishSelector:@selector(apiTicket:didFinishWithData:)
                  didFailSelector:@selector(authorize:didFailWithError:)];
}

- (void) apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"apiTicket:didFinishWithData:");
    NSString *responseBody = [[NSString alloc] initWithData:data 
                                                       encoding:NSUTF8StringEncoding];
    NSLog(@"%@", responseBody);
    
    [_accessToken release];
    _accessToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] retain];
    
    [self currentUser];
}

- (void)currentUser {
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://api.rdio.com/1/"];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:_consumer
                                                                      token:_accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    OARequestParameter *methodParamter = [OARequestParameter requestParameterWithName:@"method" value:@"currentUser"];
    [request setParameters:[NSArray arrayWithObjects:methodParamter, nil]];
    
    [fetcher fetchDataWithRequest:request 
                         delegate:self
                didFinishSelector:@selector(currentUser:didFinishWithData:)
                  didFailSelector:@selector(authorize:didFailWithError:)];
}

- (void) currentUser:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"currentUser:didFinishWithData:");
    
    // Deserialize the current user
	_currentUser = [[[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil] retain];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://api.rdio.com/1/"];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:_consumer
                                                                      token:_accessToken
                                                                      realm:nil
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    OARequestParameter *methodParamter = [OARequestParameter requestParameterWithName:@"method" value:@"getPlaybackToken"];
    [request setParameters:[NSArray arrayWithObjects:methodParamter, nil]];
    
    [fetcher fetchDataWithRequest:request 
                         delegate:self
                didFinishSelector:@selector(playbackToken:didFinishWithData:)
                  didFailSelector:@selector(authorize:didFailWithError:)];
}

- (void) playbackToken:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSLog(@"playbackToken:didFinishWithData:");

    // Deserialize the station list response
	NSDictionary *playbackTokenJson = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil];
    _playbackToken = [[playbackTokenJson valueForKey:@"result"] retain];
    NSLog(@"playbackToken: %@", _playbackToken);
    
    if ([self respondsToSelector: @selector(rdioDidAuthorizeUser:withAccessToken:)]) {
        [self rdioDidAuthorizeUser:_currentUser withAccessToken:_accessToken];
    }
}

- (void) authorize:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"authorize:didFailWithError:");
    NSLog(@"%@", [error description]);
}

#pragma mark -
#pragma mark NSSearchField delegate methods

- (IBAction)didSearchArtists:(NSSearchField *)searchField
{
    NSString *searchString = [searchField stringValue];
    NSLog(@"%@", searchString);
    if ([searchString length] > 2)
        [self searchArtists:searchString];
}

#pragma mark -
#pragma mark NSTableView datasource and delegate methods

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (int)[_tableViewDataSource count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSDictionary *rowDictionary = [_tableViewDataSource objectAtIndex:rowIndex];
    if ([rowDictionary valueForKey:@"canStream"])
        return [NSString stringWithFormat:@"%@ | %@ | %@", [rowDictionary valueForKey:@"name"], [rowDictionary valueForKey:@"displayDate"], [rowDictionary valueForKey:@"length"]];
    return [rowDictionary valueForKey:@"name"];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return NO;
}

- (IBAction)didSelectArtist:(NSTableView *)theTableView {
    NSLog(@"%ld", [theTableView clickedRow]);
    NSDictionary *data = [_tableViewDataSource objectAtIndex:[theTableView clickedRow]];
    
    if ([data valueForKey:@"trackKeys"]) {
        [progressIndicator startAnimation:self];
        for (NSString *trackKey in [data valueForKey:@"trackKeys"])
            [self getPlaybackInfo:trackKey];
        [progressIndicator stopAnimation:self];
        return;
    }
    
    [self getAlbumsForArtist:[data valueForKey:@"key"]];
}

@end
