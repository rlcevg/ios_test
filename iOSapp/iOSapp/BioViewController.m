//
//  BioViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "BioViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BioViewController ()

@property (strong, nonatomic) Person *person;
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
{
    return NO;
}

@end
