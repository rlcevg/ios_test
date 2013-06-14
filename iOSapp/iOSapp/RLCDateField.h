//
//  RLCDateField.h
//  iOSapp
//
//  Created by Evgenij on 6/13/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLCDateFieldDelegate.h"

@interface RLCDateField : UITextField

@property (assign, nonatomic) id<RLCDateFieldDelegate> editDelegate;
@property (weak, nonatomic, readonly) UIDatePicker *dateView;
@property (assign, nonatomic) NSDate *date;

@end
