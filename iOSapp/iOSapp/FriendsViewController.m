//
//  FriendsViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/15/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "FriendsViewController.h"


@interface FriendsViewController ()

@end


@implementation FriendsViewController

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
    self.delegate = self;
    self.allowsMultipleSelection = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Next code is according to ios-sdk-tutorial/show-friends/
// Do we really need it?
- (void)dealloc
{
    self.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
    [self clearSelection];
}

- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker
{
    if (friendPicker.selection.count) {
        id<FBGraphUser> friend = friendPicker.selection[0];
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *url;
        if ([app canOpenURL:[NSURL URLWithString:@"fb://"]]) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", friend[@"id"]]];
        } else {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", friend[@"id"]]];
        }
        [app openURL:url];
    }
}

@end
