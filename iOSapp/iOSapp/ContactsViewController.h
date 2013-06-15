//
//  ContactsViewController.h
//  iOSapp
//
//  Created by Evgenij on 6/4/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataTabBarController.h"

@interface ContactsViewController : UITableViewController <DataTab, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navigation;

@end
