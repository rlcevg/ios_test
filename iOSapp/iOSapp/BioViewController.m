//
//  BioViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "BioViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Person.h"

typedef enum {BIOVIEW_SAVE_BUTTON, BIOVIEW_CANCEL_BUTTON} BIOVIEW_BUTTONS;


@interface BioViewController ()

@property (strong, nonatomic) Person *person;
@property (assign, nonatomic) BIOVIEW_BUTTONS pressedButton;

- (void)configureView;

@end


@implementation BioViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configureView];
    self.bioText.layer.borderWidth = 2.0f;
    self.bioText.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bioText.layer.cornerRadius = 8;
    self.bioText.editDelegate = self;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.bioText.frame = CGRectMake(0.0f, 0.0f, keyboardFrame.size.width, keyboardFrame.origin.y);
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    self.bioText.frame = self.view.frame;
    [UIView commitAnimations];
}

- (void)configureView
{
    if (self.person) {
        self.bioText.text = self.person.bio;
        self.bioText.editable = YES;
    } else {
        self.bioText.editable = NO;
    }
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

#pragma mark - UITextViewDelegate protocol

- (BOOL)textViewShouldBeginEditing:(RLCTextView *)textView
{
    textView.editing = YES;
    return YES;
}

#pragma mark - RLCTextViewDelegate protocol

- (void)textViewWillSave:(RLCTextView *)textView
{
    self.pressedButton = BIOVIEW_SAVE_BUTTON;
    [[[UIActionSheet alloc] initWithTitle:@"Are you sure?"
                                 delegate:self
                        cancelButtonTitle:@"No"
                   destructiveButtonTitle:@"Yes, save text"
                        otherButtonTitles:nil] showInView:self.tabBarController.tabBar.superview];
}

- (void)textViewWillCancel:(RLCTextView *)textView
{
    self.pressedButton = BIOVIEW_CANCEL_BUTTON;
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Are you sure?"
                                                            delegate:self
                                                   cancelButtonTitle:@"No"
                                              destructiveButtonTitle:@"Yes, cancel editing"
                                                   otherButtonTitles:nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [popupQuery showInView:self.tabBarController.tabBar.superview];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (self.pressedButton) {
        case BIOVIEW_SAVE_BUTTON:
            if (buttonIndex == 0) {
                [self textViewSave:self.bioText];
            }
            break;
        case BIOVIEW_CANCEL_BUTTON:
        default:
            if (buttonIndex == 0) {
                [self textViewCancel:self.bioText];
            }
    }
}

- (void)textViewSave:(RLCTextView *)textView
{
    textView.editing = NO;
    self.person.bio = textView.text;
    [(DataTabBarController *)self.parentViewController saveContext];
}

- (void)textViewCancel:(RLCTextView *)textView
{
    textView.editing = NO;
    textView.text = self.person.bio;
}

@end
