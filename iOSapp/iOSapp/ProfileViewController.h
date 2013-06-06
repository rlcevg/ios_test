//
//  ProfileViewController.h
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataTab.h"

@interface ProfileViewController : UIViewController <DataTab>
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *surnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdateLabel;

@property (weak, nonatomic) IBOutlet UIView *textContainer;
@end
