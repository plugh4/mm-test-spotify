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
    
    // lock screen
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseResumeSong) name:@"RemoteControlTogglePlayPause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipSong) name:@"RemoteControlNextTrack" object:nil];
}
-(void)initSpotify {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));

    self.session = [SPTAuth defaultInstance].session;
    self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    
    // delegate         => <SPTAudioStreamingDelegate>
    // playbackDelegate => <SPTAudioStreamPlaybackDelegate>
    self.player.delegate = self;
    self.player.playbackDelegate = self;

    [self.player loginWithSession:self.session callback:^(NSError *error) {
        if (error) { NSLog(@"*** Spotify player login error: %@", error); }
    }];

}


#pragma mark - Lock Screen 
- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark - Play Song
NSURL *urify(NSString *trackID) {
    //NSString *canonicalName = [NSString stringWithFormat:@"spotify:track:%@", trackID];
    return [NSURL URLWithString:trackID];
}

-(void)playSong {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    
    NSString *track1 = @"spotify:track:1li0jGGRIaMaNNRBV8JXZ4"; // Final Countdownnnnnnnn
    NSString *track2 = @"spotify:track:2HHtWyy5CgaQbC7XSoOb0e"; // Eye of the Tiger
    NSString *track3 = @"spotify:track:5GnhAFE3KwluAECpx9Csw7"; // 13 Variations
    NSString *track4 = @"spotify:track:5fA73CY02uyQko1uPRmO2e"; // Rage
    NSString *track5 = @"spotify:track:4vvOv6MDFFPpEb1gwwb2ZD"; // Baby Got Back
    
    NSArray *playlist = @[
        urify(track1),
        urify(track5),
        urify(track2),
        urify(track3),
        urify(track4)
    ];
    
    //[self.player playURIs:@[ trackURI, trackURI2, trackURI3, trackURI4 ] fromIndex:0 callback:^(NSError *error) {
    [self.player playURIs:playlist fromIndex:0 callback:^(NSError *error) {
        if (error) {
            NSLog(@"*** Playback error: %@", error);
            return;
        }
        NSLog(@"playURIs callback");
        
        if ([((NSURL *)playlist[0]).absoluteString containsString:@"1li0jGGRIaMaNNRBV8JXZ4"]) {
            // Final Countdown 0:13
            [self performSelector:@selector(seekTo:) withObject:[NSNumber numberWithDouble:13.0] afterDelay:1.0];
        } else if ([((NSURL *)playlist[0]).absoluteString containsString:@"4vvOv6MDFFPpEb1gwwb2ZD"]) {
            // Baby Got Back 0:31.5
            [self performSelector:@selector(seekTo:) withObject:[NSNumber numberWithDouble:31.5] afterDelay:6.5];
        }

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
    // stop() - stops playback and wipes the entire playlist (sans resume)
    // use setIsPlaying() instead
}


#pragma mark - Spotify streaming "delegate"
- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"[%@ delegate.%@]", self.class, NSStringFromSelector(_cmd));
}
-(void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"[%@ delegate.%@]", self.class, NSStringFromSelector(_cmd));
}
- (void)audioStreamingDidEncounterTemporaryConnectionError:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"[%@ delegate.%@]", self.class, NSStringFromSelector(_cmd));
}
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didEncounterError:(NSError *)error {
    NSLog(@"[%@ delegate.%@]", self.class, NSStringFromSelector(_cmd));
}
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    NSLog(@"[%@ delegate.%@]", self.class, NSStringFromSelector(_cmd));
}
-(void)audioStreamingDidDisconnect:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"[%@ delegate.%@]", self.class, NSStringFromSelector(_cmd));
}
-(void)audioStreamingDidReconnect:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"[%@ delegate.%@]", self.class, NSStringFromSelector(_cmd));
}


#pragma mark - Spotify streaming "playbackDelegate"
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"[%@ playbackDelegate.%@] %@", self.class, NSStringFromSelector(_cmd), (isPlaying) ? (@"play") : (@"stop"));
}
- (void)audioStreamingDidPopQueue:(SPTAudioStreamingController *)audioStreaming {
    NSLog(@"[%@ playbackDelegate.%@]", self.class, NSStringFromSelector(_cmd));
}
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri {
    NSLog(@"[%@ playbackDelegate.%@]", self.class, NSStringFromSelector(_cmd));
    //NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), trackUri.absoluteString);
}
-(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri {
    NSLog(@"[%@ playbackDelegate.%@]", self.class, NSStringFromSelector(_cmd));
    //NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), trackUri.absoluteString);
}
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri {
    NSLog(@"[%@ playbackDelegate.%@]", self.class, NSStringFromSelector(_cmd));
    //NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), trackUri.absoluteString);
}


-(void)testArtistData {
    for (NSString *artist in self.headliners) {
        [self fetchArtist:artist];
    }
}

#pragma mark - Artist/Top Songs
-(void)fetchArtist2:(NSString *)artist {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    NSString *accessToken = self.session.accessToken;
    [SPTSearch performSearchWithQuery:artist queryType:SPTQueryTypeArtist accessToken:accessToken callback:^(NSError *error, id object) {
        if (error) { NSLog(@"ArtistQuery error - %@", error.localizedDescription); }
        SPTListPage *listPage = object;
        SPTPartialArtist *artist = listPage.items.firstObject;
        [self fetchFullArtistFromPartial2:artist];
    }];
}
-(void)fetchFullArtistFromPartial2:(SPTPartialArtist *)partialArtist {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    [SPTArtist artistWithURI:partialArtist.uri session:self.session callback:^(NSError *error, id object) {
        if (error) { NSLog(@"[%@ %@] =>artistWithURI", self.class, NSStringFromSelector(_cmd)); }
        SPTArtist *fullArtist = object;
        // do something with fullArtist
        [self getTopSongsForArtist2:fullArtist];
    }];
}
-(void)getTopSongsForArtist2:(SPTArtist *)artist {
    NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), artist);
    SPTSession *session = [SPTAuth defaultInstance].session;
    [artist requestTopTracksForTerritory:@"us" withSession:session callback:^(NSError *error, id object) {
        NSLog(@"[%@ %@] %@ =>callback", self.class, NSStringFromSelector(_cmd), artist);
        NSArray *tracks = object;
        for (SPTTrack *track in tracks) {
            NSLog(@"   track=%0.1lf %@", track.popularity, track);
        }
    }];
}


-(void)fetchArtist:(NSString *)artist {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    NSString *accessToken = self.session.accessToken;

    // get partialArtist (text search)
    [SPTSearch performSearchWithQuery:artist queryType:SPTQueryTypeArtist accessToken:accessToken callback:^(NSError *error, id object) {
        if (error) { NSLog(@"ArtistQuery error - %@", error.localizedDescription); }
        SPTListPage *listPage = object;
        SPTPartialArtist *partialArtist = listPage.items.firstObject;
        NSLog(@"[%@ %@] =>performSearchWithQuery", self.class, NSStringFromSelector(_cmd));
        NSLog(@"   name=%@", partialArtist.name);
        NSLog(@"   uri =%@", partialArtist.uri.absoluteString);

        // get fullArtist from partialArtist
        [SPTArtist artistWithURI:partialArtist.uri session:self.session callback:^(NSError *error, id object) {
            if (error) { NSLog(@"[%@ %@] =>artistWithURI", self.class, NSStringFromSelector(_cmd)); }
            SPTArtist *fullArtist = object;
            // do something with fullArtist
            NSLog(@"[%@ %@] =>artistWithURI", self.class, NSStringFromSelector(_cmd));
            for (NSString *genre in fullArtist.genres) {
                NSLog(@"   name=%@", partialArtist.name);
                NSLog(@"   genre=%@", genre);
            }

            [self getTopSongsForArtist:fullArtist];
        }];
    }];
}
-(void)getTopSongsForArtist:(SPTArtist *)artist {
    NSLog(@"[%@ %@] %@", self.class, NSStringFromSelector(_cmd), artist);
    SPTSession *session = [SPTAuth defaultInstance].session;
    [artist requestTopTracksForTerritory:@"us" withSession:session callback:^(NSError *error, id object) {

        // >>> topTracks
        
        NSLog(@"[%@ %@] %@ =>callback", self.class, NSStringFromSelector(_cmd), artist);
        NSArray *tracks = object;
        for (SPTTrack *track in tracks) {
            NSLog(@"   track=%0.1lf %@", track.popularity, track);
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
    [self testArtistData];
}



@end
