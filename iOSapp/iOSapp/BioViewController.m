//
//  BioViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "BioViewController.h"

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

@end
