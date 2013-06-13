//
//  BioViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "BioViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DataTabBarController.h"

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
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, 205.0f);
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, 100.0f);
        [UIView commitAnimations];
    }
    textView.editing = YES;
    return YES;
}

#pragma mark - RLCTextViewDelegate protocol

- (void)textViewOnSave:(RLCTextView *)textView
{
    self.pressedButton = BIOVIEW_SAVE_BUTTON;
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Are you sure?"
                                                            delegate:self
                                                   cancelButtonTitle:@"No"
                                              destructiveButtonTitle:@"Yes, save text"
                                                   otherButtonTitles:nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
//    [popupQuery showFromTabBar:self.tabBarController.tabBar];
    [popupQuery showInView:self.tabBarController.tabBar.superview];
}

- (void)textViewOnCancel:(RLCTextView *)textView
{
    self.pressedButton = BIOVIEW_CANCEL_BUTTON;
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Are you sure?"
                                                            delegate:self
                                                   cancelButtonTitle:@"No"
                                              destructiveButtonTitle:@"Yes, cancel editing"
                                                   otherButtonTitles:nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
//    [popupQuery showFromTabBar:self.tabBarController.tabBar];
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
    [self restoreTextView:textView];
    self.person.bio = textView.text;
    [(DataTabBarController *)self.parentViewController saveContext];
}

- (void)textViewCancel:(RLCTextView *)textView
{
    [self restoreTextView:textView];
    textView.text = self.person.bio;
}

- (void)restoreTextView:(RLCTextView *)textView
{
    textView.editing = NO;
    [UIView animateWithDuration:0.3 animations:^{
        textView.frame = self.view.frame;
    }];
}

#pragma mark - Orientation behavior

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (self.bioText.editing) {
        [UIView animateWithDuration:0.1 animations:^{
            if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                self.bioText.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 205.0f);
            } else {
                self.bioText.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 100.0f);
            }
        }];
    }
}

@end
