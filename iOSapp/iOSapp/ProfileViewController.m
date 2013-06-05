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

#pragma mark - Orientation behavior

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateViewLayout];
}

- (void)updateViewLayout
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.photoView.center = CGPointMake(160.0f, 84.0f);
        self.titleName.frame = CGRectMake(20.0f, 167.0f, 280.0f, 21.0f);
        self.titleName.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.frame = CGRectMake(20.0f, 196.0f, 280.0f, 21.0f);
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.titleSurname.frame = CGRectMake(20.0f, 240.0f, 280.0f, 21.0f);
        self.titleSurname.textAlignment = NSTextAlignmentCenter;
        self.surnameLabel.frame = CGRectMake(20.0f, 269.0f, 280.0f, 21.0f);
        self.surnameLabel.textAlignment = NSTextAlignmentCenter;
        self.titleBirthdate.frame = CGRectMake(20.0f, 319.0f, 280.0f, 21.0f);
        self.titleBirthdate.textAlignment = NSTextAlignmentCenter;
        self.birthdateLabel.frame = CGRectMake(20.0f, 348.0f, 280.0f, 21.0f);
        self.birthdateLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        self.photoView.center = CGPointMake(84.0f, 84.0f);
        self.titleName.frame = CGRectMake(156.0f, 20.0f, 52.0f, 18.0f);
        self.titleName.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.frame = CGRectMake(156.0f, 46.0f, 304.0f, 21.0f);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.titleSurname.frame = CGRectMake(156.0f, 75.0f, 78.0f, 18.0f);
        self.titleSurname.textAlignment = NSTextAlignmentLeft;
        self.surnameLabel.frame = CGRectMake(156.0f, 101.0f, 304.0f, 21.0f);
        self.surnameLabel.textAlignment = NSTextAlignmentLeft;
        self.titleBirthdate.frame = CGRectMake(156.0f, 130.0f, 74.0f, 18.0f);
        self.titleBirthdate.textAlignment = NSTextAlignmentLeft;
        self.birthdateLabel.frame = CGRectMake(156.0f, 156.0f, 304.0f, 21.0f);
        self.birthdateLabel.textAlignment = NSTextAlignmentLeft;
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
        self.nameLabel.text = self.person.name;
        self.surnameLabel.text = self.person.surname;
        self.birthdateLabel.text = [self.person.birthdate description];
        self.photoView.image = self.person.photo;
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

@end
