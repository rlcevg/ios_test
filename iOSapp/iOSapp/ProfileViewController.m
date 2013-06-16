//
//  ProfileViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "ProfileViewController.h"
#import "Person.h"


@interface ProfileViewController ()

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) UITextField *activeField;
@property (assign, nonatomic) CGRect keyboardFrame;
@property (strong, nonatomic) NSString *undoText;
@property (assign, nonatomic, getter=isRotating) BOOL rotating;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

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

    if (!self.rotating) {
        [self keyboardPopup];
    }
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
    CGRect textFieldFrame = [self.view convertRect:self.activeField.frame fromView:self.activeField.superview];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if (self.activeField && (self.activeField != touch.view)) {
        // Cancel text editing
        [self activeFieldCancel];
    } else if (!self.activeField && self.photoView.superview == touch.view && self.person) {
        // Show image picker
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
}

- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePicker;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.photoView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
    self.person.photo = self.photoView.image;
    [(DataTabBarController *)self.parentViewController saveContext];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.rotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [UIView animateWithDuration:0.4 animations:^{
        [self updateViewLayout];
    } completion:^(BOOL finished){
        self.rotating = NO;
        if (self.activeField) {
            [self keyboardPopup];
        }
    }];
}

- (void)configureView
{
    if (self.person) {
        [self populateUserDetails];
        if (self.person.photo) {
            [self populateUserPhoto];
        }
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

#pragma mark - UITextFieldDelegate protocol

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL result = !self.activeField;
    if (result == NO) {
        [self activeFieldCancel];
    } else {
        result = result && self.person;
    }
    return result;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    self.undoText = textField.text;
    if (textField == self.birthdateText) {
        self.birthdateText.date = self.person.birthdate;
        self.birthdateText.dateView.maximumDate = [NSDate date];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 2 && textField.text.length <= 40) {
        if ([self activeFieldShouldSave]) {
            if (textField == self.nameText) {
                self.person.name = textField.text;
            } else if (textField == self.surnameText) {
                self.person.surname = textField.text;
            }
            [(DataTabBarController *)self.parentViewController saveContext];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Validation error"
                                   message:@"Length of name and surname must be greater than 2 chars and less than 40 chars"
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:nil] show];
    }
    return NO;
}

- (BOOL)activeFieldShouldSave
{
    BOOL result = ![self.undoText isEqualToString:self.activeField.text];
    [self.activeField resignFirstResponder];
    return result;
}

- (void)activeFieldCancel
{
    self.activeField.text = self.undoText;
    [self.activeField resignFirstResponder];
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
    if ([self activeFieldShouldSave]) {
        self.person.birthdate = dateField.date;
        [(DataTabBarController *)self.parentViewController saveContext];
    }
}

- (void)dateFieldWillCancel:(RLCDateField *)dateField
{
    [self activeFieldCancel];
}

- (void)dateFieldDidChangeDate:(RLCDateField *)dateField
{
    dateField.text = [self.dateFormatter stringFromDate:dateField.date];
}

@end
