//
//  ProfileViewController.h
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "DataTabBarController.h"
#import "RLCDateField.h"

@interface ProfileViewController : UIViewController <DataTab, FBLoginViewDelegate, UITextFieldDelegate, RLCDateFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *surnameText;
@property (weak, nonatomic) IBOutlet RLCDateField *birthdateText;

@property (weak, nonatomic) IBOutlet UIView *textContainer;
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (weak, nonatomic) IBOutlet UIView *photoContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (void)populateUserDetails;
- (void)populateUserPhoto;

@end
