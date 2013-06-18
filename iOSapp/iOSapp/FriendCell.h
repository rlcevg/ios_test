//
//  FriendCell.h
//  iOSapp
//
//  Created by Evgenij on 6/18/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBGraphObjectTableCell.h"
#import "FriendsViewController.h"
#import "Friend.h"

@interface FriendCell : FBGraphObjectTableCell <UITextFieldDelegate>

@property (weak, nonatomic) FriendsViewController *controller;
@property (weak, nonatomic) UITextField *priorityField;
@property (weak, nonatomic) Friend *friend;

@end
