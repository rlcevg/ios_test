//
//  FriendsViewController.h
//  iOSapp
//
//  Created by Evgenij on 6/18/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface FriendsViewController : UIViewController </*FBRequestDelegate, */UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITextField *activeField;
- (void)updateView;
- (void)saveContext;

@end
