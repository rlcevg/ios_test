//
//  ContactsViewController.h
//  iOSapp
//
//  Created by Evgenij on 6/4/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataTab.h"

@interface ContactsViewController : UITableViewController <DataTab>

@property (strong, nonatomic) NSArray *contacts;

@end
