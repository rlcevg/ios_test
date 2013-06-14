//
//  RLCDateFieldDelegate.h
//  iOSapp
//
//  Created by Evgenij on 6/13/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RLCDateField;

@protocol RLCDateFieldDelegate <NSObject>

@required
- (void)dateFieldWillSave:(RLCDateField *)dateField;
- (void)dateFieldWillCancel:(RLCDateField *)dateField;

@optional
- (void)dateFieldDidChangeDate:(RLCDateField *)dateField;

@end
