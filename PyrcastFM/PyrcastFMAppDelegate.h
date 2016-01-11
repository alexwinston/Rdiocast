//
//  PyrcastFMAppDelegate.h
//  PyrcastFM
//
//  Created by Alex Winston on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "BWTransparentScrollView.h"
#include "BWTransparentTableView.h"
#include "OAToken.h"

@interface PyrcastFMAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *progressTextField;
    IBOutlet BWTransparentScrollView *scrollView;
    IBOutlet BWTransparentTableView *tableView;
    NSMutableArray *_tableViewDataSource;
    
    OAConsumer *_consumer;
    OAConsumer *_rdioConsumer;
    
    NSString *_email;
    NSString *_password;
    OAToken *_accessToken;
    NSDictionary *_currentUser;
    NSString *_playbackToken;
    NSString *_playerName;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)didSearchArtists:(NSSearchField *)searchField;
- (IBAction)didSelectArtist:(NSTableView *)theTableView;
- (void)initWithConsumerKey:(NSString *)consumerKey secret:(NSString *)secret;
- (void)authorizeWithEmail:(NSString *)email password:(NSString *)password;
- (void)authorizeWithToken:(NSString *)token;
- (void)currentUser;
- (void)searchArtists:(NSString *)name;
- (void)rdioDidSearchArtists:(NSDictionary *)artists error:(NSError *)error;
- (void)getAlbumsForArtist:(NSString *)artistKey;
- (void)rdioDidGetAlbumsForArtist:(NSDictionary *)albums error:(NSError *)error;
- (void)getPlaybackInfo:(NSString *)trackKey;
- (void)rdioDidGetPlaybackInfo:(NSDictionary *)playbackInfo error:(NSError *)error;
@end
