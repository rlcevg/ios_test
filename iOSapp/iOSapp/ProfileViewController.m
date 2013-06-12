//
//  ProfileViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@property (strong, nonatomic) Person *person;
- (void)configureView;

@end

@implementation ProfileViewController

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
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateViewLayout];
}

#pragma mark - Orientation behavior

- (void)updateViewLayout
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.photoContainer.center = CGPointMake(160.0f, 84.0f);
        self.textContainer.center = CGPointMake(160.0f, 239.0f);
        self.fbLoginView.center = CGPointMake(160.0f, 368.0f);
    } else {
        self.photoContainer.center = CGPointMake(95.0f, 84.0f);
        self.textContainer.center = CGPointMake(320.0f, 103.0f);
        self.fbLoginView.center = CGPointMake(96.0f, 210.0f);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [UIView animateWithDuration:0.5 animations:^{
        [self updateViewLayout];
    }];
}

- (void)configureView
{
    if (self.person) {
        [self populateUserDetails];
        [self populateUserPhoto];
    } else {
        [self.spinner startAnimating];
    }
}

- (void)populateUserDetails
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }

    self.nameLabel.text = self.person.name;
    self.surnameLabel.text = self.person.surname;
    self.birthdateLabel.text = [dateFormatter stringFromDate:self.person.birthdate];
}

- (void)populateUserPhoto
{
    self.photoView.image = self.person.photo;
    [self.spinner stopAnimating];
}

- (void)setPerson:(Person *)person
{
    if (_person != person) {
        _person = person;

        // Update the view.
        [self configureView];
    }
}

#pragma mark - DataTab protocol

- (void)prepareData:(Person *)person
{
    self.person = person;
}

#pragma mark - FBLoginViewDelegate protocol

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. Here we simply pop back to the landing page.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"isLoggedIn"];
    [defaults synchronize];

    [self.navigationController popToRootViewControllerAnimated:YES];
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

@end
