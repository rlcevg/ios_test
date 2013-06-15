//
//  BioViewController.h
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataTabBarController.h"
#import "RLCTextView.h"

@interface BioViewController : UIViewController <UITextViewDelegate, DataTab, RLCTextViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet RLCTextView *bioText;

@end
