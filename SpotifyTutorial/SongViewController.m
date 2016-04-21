//
//  SongViewController.m
//  SpotifyTutorial
//
//  Created by Michael Merrill on 4/19/16.
//  Copyright © 2016 Michael Merrill. All rights reserved.
//

#import "SongViewController.h"


@interface SongViewController () <SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property NSArray *headliners;
@property NSArray *openers;
@end


@implementation SongViewController
- (void)viewDidLoad {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));

    [super viewDidLoad];

    [self initSpotify];
    
    // dummy data: Artists
    self.headliners = @[@"CHVRCHES", @"Wolf Alice", @"DeerHunter", @"Savages", @"Jon McLaughlin", @"GirlPool", @"Heather Nova", @"Fat White Family", @"Alejandro Escovedo", @"Hælos", @"There's Talk"];
    self.openers = @[@"Ian", @"Smokin Ziggurats", @"Bitchin Bajas", @"Bob Doran", @"Parachute", @"The French Vanilla", @"Try the Pie"];
    //[self getArtistSpotifyID];
}
-(void)initSpotify {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));

    self.session = [SPTAuth defaultInstance].session;
    self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    
    // player.delegate is for <SPTAudioStreamingDelegate>
    // player.playbackDelegate is for <SPTAudioStreamPlaybackDelegate>
    self.player.delegate = self;
    self.player.playbackDelegate = self;

    [self.player loginWithSession:self.session callback:^(NSError *error) {
        if (error) { NSLog(@"*** Spotify player login error: %@", error); }
    }];

}


#pragma mark - Play Song

-(void)playSong {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    
    NSString *track1 = @"spotify:track:1li0jGGRIaMaNNRBV8JXZ4"; // it's the final countdownnnnnnnn
    NSURL *trackURI = [NSURL URLWithString:track1];

    NSString *track2 = @"spotify:track:2HHtWyy5CgaQbC7XSoOb0e";
    NSURL *trackURI2 = [NSURL URLWithString:track2];

    NSString *track3 = @"spotify:track:5GnhAFE3KwluAECpx9Csw7";
//    NSString *track3 = @"spotify:track:673Adebta6FzZsMGLbCmRL";
    NSURL *trackURI3 = [NSURL URLWithString:track3];

    NSString *track4 = @"spotify:track:5fA73CY02uyQko1uPRmO2e";
    NSURL *trackURI4 = [NSURL URLWithString:track4];
    
    [self.player playURIs:@[ trackURI, trackURI2, trackURI3, trackURI4 ] fromIndex:0 callback:^(NSError *error) {
        if (error) {
            NSLog(@"*** Playback error: %@", error);
            return;
        }
        NSLog(@"playURIs callback");
        
        [self performSelector:@selector(seekTo:) withObject:[NSNumber numberWithDouble:13.0] afterDelay:1.0];
        
        self.pauseButton.enabled = YES;
        self.skipButton.enabled = YES;
    }];
}

-(void)seekTo:(NSNumber *)offset_obj {
    NSTimeInterval offset = offset_obj.doubleValue;
    [self.player seekToOffset:offset callback:^(NSError *error) {
        NSLog(@"seekTo callback");
    }];
}

- (void)pauseResumeSong {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    BOOL isPlaying = self.player.isPlaying;
    [self.player setIsPlaying:!isPlaying callback:^(NSError *error) {
        NSLog(@"setIsPlaying callback");

        // change button
        NSString *buttonLabel = (self.player.isPlaying) ? (@"⏸") : (@"▶️");
        [self.pauseButton setTitle:buttonLabel forState:UIControlStateNormal];
    }];
    
}
- (void)skipSong {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    [self.player skipNext:^(NSError *error) {
        NSLog(@"skipNext callback");
        if (error) { NSLog(@"skipNext error: %@", error.localizedDescription); }
    }];
}


// do not use
-(void)stopSong {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));

    [self.player stop:^(NSError *error) {
        if (error) { NSLog(@">>> error stopping playback"); }
    }];
    // stop() - stops playback and wipes the entire playlist (no resume)
    // use setIsPlaying() instead
}


#pragma mark - SPTAudioStreamingDelegate
- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
}


#pragma mark - Playback delegates
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), (isPlaying) ? (@"play") : (@"stop"));
}
- (void)audioStreamingDidPopQueue:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
}
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    //NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), trackUri.absoluteString);
}
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    //NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), trackUri.absoluteString);
}
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    //NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), trackUri.absoluteString);
}


#pragma mark - Artist/Top Songs

-(void)getArtistSpotifyID {
    NSString *accessToken = self.session.accessToken;
    for (NSString *artist in self.headliners) {
        [SPTSearch performSearchWithQuery:artist queryType:SPTQueryTypeArtist accessToken:accessToken callback:^(NSError *error, id object) {
            if (error != nil) {
                NSLog(@"Error while getting artist id: %@", error.localizedDescription);
            }
            
            SPTListPage *listPage = object;
            SPTPartialArtist *artist = listPage.items.firstObject;
            
            [self getFullArtist:artist];
//            if ([SPTArtist isArtistURI:artist.uri]) {
//                NSLog(@"Success");
//            } else {
//                NSLog(@"Fuck me, right?");
//            }
        }];
    }
}

-(void)getFullArtist:(SPTPartialArtist *)partialArtist {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    [SPTArtist artistWithURI:partialArtist.uri session:self.session callback:^(NSError *error, id object) {
        NSLog(@"[%@ %@] artistWithURI callback", self.class, NSStringFromSelector(_cmd));
        SPTArtist *fullArtist = object;
        [self getTopSongsForArtist:fullArtist];
        
    }];
}

-(void)getTopSongsForArtist:(SPTArtist *)artist {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    SPTSession *session = [SPTAuth defaultInstance].session;
    [artist requestTopTracksForTerritory:@"us" withSession:session callback:^(NSError *error, id object) {
        NSLog(@"[%@ %@] requestTopTracksForTerritory callback", self.class, NSStringFromSelector(_cmd));
        NSArray *tracks = object;
        for (SPTTrack *track in tracks) {
            NSLog(@"   track=%@", track);
            NSLog(@"   track=%@", track);
        }
    }];
    
}




#pragma mark - Buttons
- (IBAction)onPlay1Pressed:(UIButton *)sender {
    [self playSong];
    
    if ([self.startButton.titleLabel.text isEqualToString:@"Push me"]) {
        [self.startButton setTitle:@"Good job" forState:UIControlStateNormal];
    } else if ([self.startButton.titleLabel.text isEqualToString:@"Good job"]) {
        [self.startButton setTitle:@"That's enough" forState:UIControlStateNormal];
    } else if ([self.startButton.titleLabel.text isEqualToString:@"That's enough"]) {
        [self.startButton setTitle:@"We get it" forState:UIControlStateNormal];
    } else if ([self.startButton.titleLabel.text isEqualToString:@"We get it"]) {
        [self.startButton setTitle:@"Stop it" forState:UIControlStateNormal];
    } else if ([self.startButton.titleLabel.text isEqualToString:@"Stop it"]) {
        [self.startButton setTitle:@"Cut it out" forState:UIControlStateNormal];
    } else if ([self.startButton.titleLabel.text isEqualToString:@"Cut it out"]) {
        [self.startButton setTitle:@"Seriously" forState:UIControlStateNormal];
    } else if ([self.startButton.titleLabel.text isEqualToString:@"Seriously"]) {
        [self.startButton setTitle:@"Really?" forState:UIControlStateNormal];
    } else if ([self.startButton.titleLabel.text isEqualToString:@"Really?"]) {
        [self.startButton setTitle:@"So annoying" forState:UIControlStateNormal];
    } else if ([self.startButton.titleLabel.text isEqualToString:@"So annoying"]) {
        [self.startButton setTitle:@"Worst user ever" forState:UIControlStateNormal];
    }

}
- (IBAction)onPause1Pressed:(UIButton *)sender {
    [self pauseResumeSong];
}
- (IBAction)onSkip2Pressed:(UIButton *)sender {
    [self.player skipNext:^(NSError *error) {
        NSLog(@"skipNext callback");
        if (error) { NSLog(@"skipNext error: %@", error.localizedDescription); }
    }];
}
- (IBAction)onFetchPressed:(UIButton *)sender {
    [self getArtistSpotifyID];
}



@end
