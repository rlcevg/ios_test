//
//  RLCDateField.h
//  iOSapp
//
//  Created by Evgenij on 6/13/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RLCDateField;

@protocol RLCDateFieldDelegate <NSObject>

@required
- (void)dateFieldWillSave:(RLCDateField *)dateField;
- (void)dateFieldWillCancel:(RLCDateField *)dateField;

@optional
- (void)dateFieldDidChangeDate:(RLCDateField *)dateField;

@end

@interface RLCDateField : UITextField

@property (assign, nonatomic) id<RLCDateFieldDelegate> editDelegate;
@property (weak, nonatomic, readonly) UIDatePicker *dateView;
@property (assign, nonatomic) NSDate *date;

@end
