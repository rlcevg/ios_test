//
//  ProfileViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "ProfileViewController.h"
#import "DataTabBarController.h"

@interface ProfileViewController ()

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) UITextField *responder;
@property (assign, nonatomic) CGRect keyboardFrame;
@property (strong, nonatomic) NSString *undoText;

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
    self.birthdateText.editDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateViewLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];

    [self keyboardPopup];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]
                     animations:^{
        self.view.frame = self.view.bounds;
    }];
}

- (void)keyboardPopup
{
    CGRect textFieldFrame = [self.view convertRect:self.responder.frame fromView:self.responder.superview];
    CGFloat deltaY = textFieldFrame.origin.y - self.keyboardFrame.origin.y + textFieldFrame.size.height;
    if (deltaY > 0) {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= deltaY;
        viewFrame.size.height += deltaY;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = viewFrame;
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    if (self.responder && (self.responder != touch.view)) {
        [self responderCancel];
    }
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
    self.nameText.text = self.person.name;
    self.surnameText.text = self.person.surname;
    self.birthdateText.text = [self.dateFormatter stringFromDate:self.person.birthdate];
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

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormatter;
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

#pragma mark - UITextFieldDelegate protocol

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL result = !self.responder;
    if (result == NO) {
        [self responderCancel];
    } else {
        result &= ![textField.text isEqualToString:@"Loading..."];
    }
    return result;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.responder = textField;
    self.undoText = textField.text;
    if (textField == self.birthdateText) {
        self.birthdateText.date = self.person.birthdate;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 2 && textField.text.length <= 40) {
        [textField resignFirstResponder];
        self.responder = nil;
        if (textField == self.nameText) {
            self.person.name = textField.text;
        } else if (textField == self.surnameText) {
            self.person.surname = textField.text;
        }
        [(DataTabBarController *)self.parentViewController saveContext];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Validation error"
                                   message:@"Length of name and surname must be greater than 3 chars and less than 40 chars"
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:nil] show];
        [self responderCancel];
    }
    return NO;
}

- (void)responderCancel
{
    [self.responder resignFirstResponder];
    self.responder.text = self.undoText;
    self.responder = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *unacceptedInput = nil;
    switch (textField.tag) {
            // Assuming nameText.tag == 1001
        case 1001:
            // Assuming surnameText.tag == 1002
        case 1002:
            if (textField.text.length + string.length > 40) {
                return NO;
            }
            unacceptedInput = [[NSCharacterSet letterCharacterSet] invertedSet];
            break;
        default:
            unacceptedInput = [[NSCharacterSet illegalCharacterSet] invertedSet];
            break;
    }
    return ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] <= 1);
}

#pragma mark - RLCDateFieldDelegate protocol

- (void)dateFieldWillSave:(RLCDateField *)dateField
{
    [dateField resignFirstResponder];
    self.responder = nil;
    self.person.birthdate = dateField.date;
    [(DataTabBarController *)self.parentViewController saveContext];
}

- (void)dateFieldWillCancel:(RLCDateField *)dateField
{
    [self responderCancel];
}

- (void)dateFieldDidChangeDate:(RLCDateField *)dateField
{
    dateField.text = [self.dateFormatter stringFromDate:dateField.date];
}

@end
