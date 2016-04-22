//
//  AppDelegate.m
//  SpotifyTutorial
//
//  Created by Michael Merrill on 4/16/16.
//  Copyright © 2016 Michael Merrill. All rights reserved.
//

#import <Spotify/Spotify.h>
#import "AppDelegate.h"
    
@interface AppDelegate ()
@end
    
@implementation AppDelegate
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SPTAuth *auth = [SPTAuth defaultInstance];
    [auth setClientID:@"567025772cc54800b440c72ac697f133"];
    [auth setRedirectURL:[NSURL URLWithString:@"spotifytutoriallogin://callback"]];
    [auth setRequestedScopes:@[SPTAuthStreamingScope]];
    
    return YES;
}

// Handle auth callback
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    NSLog(@"   url=%@", url.absoluteString);
    NSLog(@"   srcApp=%@", sourceApplication);
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error,SPTSession *session) {
    
            if (error != nil) {
                NSLog(@"*** Auth error: %@", error);
                return;
            }
    
            [SPTAuth defaultInstance].session = session;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    
        }];
        
        return YES;
    }

    return NO;
}


#pragma mark - Lock Screen
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {

    //[MusicManager pauseResume];
    //[MusicManager skipForward];
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        //NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
        //NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), receivedEvent);
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
                NSLog(@"[%@ %@] Play", self.class, NSStringFromSelector(_cmd));
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlTogglePlayPause" object:self];
                break;
            case UIEventSubtypeRemoteControlPause:
                NSLog(@"[%@ %@] Pause", self.class, NSStringFromSelector(_cmd));
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlTogglePlayPause" object:self];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"[%@ %@] TogglePlayPause", self.class, NSStringFromSelector(_cmd));
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlTogglePlayPause" object:self];
                break;
                
                //TODO: pause takes us out of the lock scree
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"[%@ %@] PreviousTrack", self.class, NSStringFromSelector(_cmd));
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlPreviousTrack" object:self];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"[%@ %@] NextTrack", self.class, NSStringFromSelector(_cmd));
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlNextTrack" object:self];
                break;

            case UIEventSubtypeRemoteControlStop:
                NSLog(@"[%@ %@] Stop", self.class, NSStringFromSelector(_cmd)); break;

            default:
                break;
        }
    }
}
@end