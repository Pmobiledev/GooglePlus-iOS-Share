//
//  ViewController.m
//  GooglePlusDemo
//
//  Created by Pranay on 4/1/14.
//  Copyright (c) 2014 Pranay. All rights reserved.
//

#import <GoogleOpenSource/GoogleOpenSource.h>
#import "ViewController.h"

static NSString * const kClientId = @"YOUR_CLIENT_ID";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)signButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.userNameLabel setHidden:YES];
    [self.emailLabel setHidden:YES];
    [self.userImageView setHidden:YES];
    [self.signOutButton setHidden:YES];
    [self.shareButton setHidden:YES];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin, @"profile" ];  // "https://www.googleapis.com/auth/plus.login" scope
    //signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    
    [signIn trySilentAuthentication];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark GPPSignInDelegate

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    if (error) {
        // Do some error handling here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[error localizedDescription] delegate:Nil cancelButtonTitle:Nil otherButtonTitles:@"Ok", nil];
        [alert show];
    } else {
        [self refreshInterfaceBasedOnSignIn];
        [self refreshUserInfo];
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}


-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        self.signInButton.hidden = YES;
        [self.signOutButton setHidden:NO];
    } else {
        self.signInButton.hidden = NO;
        [self.signOutButton setHidden:YES];
    }
}

- (void)disconnect {
    [[GPPSignIn sharedInstance] disconnect];
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSLog(@"Received error %@", error);
    } else {
        // The user is signed out and disconnected.
        // Clean up user data as specified by the Google+ terms.
        [self refreshInterfaceBasedOnSignIn];
        [self refreshUserInfo];
    }
}

- (IBAction)signButtonAction:(id)sender
{
    [[GPPSignIn sharedInstance] signOut];
    [self refreshInterfaceBasedOnSignIn];
    [self refreshUserInfo];
}

// Update the interface elements containing user data to reflect the
// currently signed in user.
- (void)refreshUserInfo {
    if ([GPPSignIn sharedInstance].authentication == nil) {
        self.userNameLabel.text = @"";
        self.emailLabel.text = @"";
        self.userImageView.image = [UIImage imageNamed:@"default_user.png"];
        
        [self.userNameLabel setHidden:YES];
        [self.emailLabel setHidden:YES];
        [self.userImageView setHidden:YES];
        [self.shareButton setHidden:YES];
        
        return;
    }
    
    [self.userNameLabel setHidden:NO];
    [self.emailLabel setHidden:NO];
    [self.userImageView setHidden:NO];
    [self.shareButton setHidden:NO];
    
    self.emailLabel.text = [GPPSignIn sharedInstance].userEmail;
    
    // The googlePlusUser member will be populated only if the appropriate
    // scope is set when signing in.
    GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
    if (person == nil) {
        return;
    }
    
    self.userNameLabel.text = person.displayName;
    
    // Load avatar image asynchronously, in background
    dispatch_queue_t backgroundQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(backgroundQueue, ^{
        NSData *avatarData = nil;
        NSString *imageURLString = person.image.url;
        if (imageURLString) {
            NSURL *imageURL = [NSURL URLWithString:imageURLString];
            avatarData = [NSData dataWithContentsOfURL:imageURL];
        }
        
        if (avatarData) {
            // Update UI from the main thread when available
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userImageView.image = [UIImage imageWithData:avatarData];
            });
        }
    });
}

//****************** SHARE *******************
- (IBAction)shareButtonAction:(id)sender {
    
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    // This line will fill out the title, description, and thumbnail from
    // the URL that you are sharing and includes a link to that URL.
   
    //URL
    //[shareBuilder setURLToShare:[NSURL URLWithString:@"https://www.example.com/restaurant/sf/1234567/"]];
    
    //TEXT
    //[shareBuilder setPrefillText:@"This pos shared through the app"];
    
    //IMAGE and TEXT
    [shareBuilder setContentDeepLinkID:@"rest=1234567"];
    [shareBuilder setTitle:@"My title" description:@"This pos shared through the app" thumbnailURL:[NSURL URLWithString:@"http://thecontentwrangler.com/wp-content/uploads/2011/08/User.png"]];
    
    [shareBuilder open];
}

@end
