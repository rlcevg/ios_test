//
//  RLCTextView.h
//  iOSapp
//
//  Created by Evgenij on 6/13/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLCTextViewDelegate.h"

@interface RLCTextView : UITextView

@property (assign, nonatomic) id<RLCTextViewDelegate> editDelegate;
@property (assign, nonatomic, getter=isEditing) BOOL editing;

@end
