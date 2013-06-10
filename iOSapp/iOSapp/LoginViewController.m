//
//  LoginViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/8/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "LoginViewController.h"
#import "RLCAppDelegate.h"
#import "DataTabBarController.h"

@interface LoginViewController ()

@property (assign, nonatomic, getter=isNewLogin) BOOL newLogin;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.fbLoginView.readPermissions = @[@"user_birthday", @"user_about_me", @"email"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueToData"]) {
        RLCAppDelegate *appDelegate = (RLCAppDelegate *)[UIApplication sharedApplication].delegate;
        DataTabBarController *controller = [segue destinationViewController];
        controller.managedObjectContext = appDelegate.managedObjectContext;
        if (self.newLogin)
            [controller reloadData];
    }
}

#pragma mark - FBLoginView delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = FBSession.activeSession.accessTokenData.accessToken;
    if (![defaults boolForKey:@"isLoggedIn"]) {
        [defaults setObject:accessToken forKey:@"accessToken"];
        [defaults setBool:YES forKey:@"isLoggedIn"];
        [defaults synchronize];
        self.newLogin = YES;
    } else {
        self.newLogin = NO;
    }

    // Upon login, transition to the main UI.
    [self performSegueWithIdentifier:@"SegueToData" sender:self];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;

    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid).

    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }

    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. Here we simply pop back to the landing page.
    [self logOut];
}

- (void)logOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"isLoggedIn"];
    [defaults synchronize];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
