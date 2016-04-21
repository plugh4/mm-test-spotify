//
//  ViewController.m
//  SpotifyTutorial
//
//  Created by Michael Merrill on 4/16/16.
//  Copyright © 2016 Michael Merrill. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SongViewController.h"
#import <SafariServices/SafariServices.h>
#import "Spotify/SPTAuth.h"



@interface ViewController ()

@property (nonatomic, strong) SPTSession *session;
@property (atomic, readwrite) SPTAuthViewController *authViewController;
@property SFSafariViewController *svc;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCompleted) name:@"sessionUpdated" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"Hello!");
}

//-(void)viewDidAppear:(BOOL)animated {
//}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    [self loginWithSafariViewController];
}

-(void)loginWithSafariViewController {
    NSString *clientID = @"567025772cc54800b440c72ac697f133";
    NSString *redirectURI = @"spotifytutoriallogin:%2F%2Fcallback";
    NSString *scopes = [NSString stringWithFormat:@"%@", SPTAuthStreamingScope];
    NSString *responseType = @"token";
    NSString *authURLStr = [NSString stringWithFormat:@"https://accounts.spotify.com/authorize/?client_id=%@&response_type=%@&redirect_uri=%@&scope=%@", clientID, responseType, redirectURI, scopes];
    NSURL *loginURL = [NSURL URLWithString:authURLStr];
    NSLog(@"auth url >%@<", authURLStr);

    self.svc = [[SFSafariViewController alloc] initWithURL:loginURL];
    
//    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//    appDelegate.svc = svc;
    
    [self presentViewController:self.svc animated:true completion:nil];
}

-(void)loginCompleted {
    [self.svc dismissViewControllerAnimated:true completion:^{
        [self goToSongVC];
    }];
}

-(void)goToSongVC {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    [self performSegueWithIdentifier:@"songVC" sender:self];
}

//-(void)openSpotifyModal {
//    self.authViewController = [SPTAuthViewController authenticationViewController];
//    self.authViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    
//    self.authViewController.delegate = self;
//    self.modalPresentationStyle = UIModalPresentationCurrentContext;
//    
//    self.definesPresentationContext = YES;
//    [self presentViewController:self.authViewController animated:NO completion:nil];
//}

//- (void)saveCanonicalUsernameToPList:(SPTSession *)session {
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"User" ofType:@"plist"];
//    NSMutableDictionary *plistdict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
//    
//    [plistdict setValue:session.canonicalUsername forKey:@"canonicalUsername"];
//    
//    [plistdict writeToFile:filePath atomically:YES];
//}
//


//// Spotify auth delegates
//- (void)authenticationViewController:(SPTAuthViewController *)authenticationViewController didFailToLogin:(NSError *)error {
//    NSLog(@"Inside didFailToLogin");
//}
//
//-(void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController {
//    NSLog(@"Inside didCancelLogin");
//}
//
//- (void) authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session {
//    
//    NSLog(@"Login Success");
//    
////    [self saveCanonicalUsernameToPList:session];
//    
//    [self performSegueWithIdentifier:@"songVC" sender:self];
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    SongViewController *destVC = [segue destinationViewController];
    destVC.session = self.session;
    NSLog(@"%@",self.session);
}




@end
