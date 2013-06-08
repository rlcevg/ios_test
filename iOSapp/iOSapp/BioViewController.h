//
//  BioViewController.h
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataTab.h"

@interface BioViewController : UIViewController <UITextViewDelegate, DataTab>
@property (weak, nonatomic) IBOutlet UITextView *bioText;

@end
