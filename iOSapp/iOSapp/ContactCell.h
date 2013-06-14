//
//  ContactCell.h
//  iOSapp
//
//  Created by Evgenij on 6/14/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface ContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *typeText;
@property (weak, nonatomic) IBOutlet UITextField *contactText;

@property (weak, nonatomic) Contact *contact;

@end
