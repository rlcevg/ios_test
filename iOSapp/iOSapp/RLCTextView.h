//
//  RLCTextView.h
//  iOSapp
//
//  Created by Evgenij on 6/13/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RLCTextView;

@protocol RLCTextViewDelegate <NSObject>

- (void)textViewConfirmSave:(RLCTextView *)textView;
- (void)textViewConfirmCancel:(RLCTextView *)textView;

@end

@interface RLCTextView : UITextView

@property (assign, nonatomic) id<RLCTextViewDelegate> editDelegate;
@property (assign, nonatomic, getter=isEditing) BOOL editing;

@end
