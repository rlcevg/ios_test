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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];
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

@end
