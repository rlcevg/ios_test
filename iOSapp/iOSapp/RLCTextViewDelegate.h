//
//  RLCTextViewDelegate.h
//  iOSapp
//
//  Created by Evgenij on 6/13/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RLCTextView;

@protocol RLCTextViewDelegate <NSObject>

@required
- (void)textViewOnSave:(RLCTextView *)textView;
- (void)textViewOnCancel:(RLCTextView *)textView;

@optional

@end
