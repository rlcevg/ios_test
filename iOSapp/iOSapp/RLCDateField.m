//
//  RLCDateField.m
//  iOSapp
//
//  Created by Evgenij on 6/13/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "RLCDateField.h"

@interface RLCDateField ()

@property (strong, nonatomic, readonly) UIToolbar *doneBar;

@end

@implementation RLCDateField

@synthesize doneBar = _doneBar;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize
{
    UIToolbar *doneBar = self.doneBar;
    doneBar.barStyle = UIBarStyleBlack;
    doneBar.translucent = YES;
    [doneBar setAlpha:0.5];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //Add buttons to the array
    NSArray *items = [NSArray arrayWithObjects:saveBtn, flexItem, cancelBtn, nil];
    [doneBar setItems:items animated:NO];
    self.inputAccessoryView = self.doneBar;
    //Change input view to Date picker
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    picker.datePickerMode = UIDatePickerModeDate;
    [picker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [picker addSubview:doneBar];
    [picker bringSubviewToFront:doneBar];
    self.inputView = picker;
}

- (void)save
{
    if ([self.editDelegate respondsToSelector:@selector(dateFieldWillSave:)]) {
        [self.editDelegate dateFieldWillSave:self];
    }
}

- (void)cancel
{
    if ([self.editDelegate respondsToSelector:@selector(dateFieldWillCancel:)]) {
        [self.editDelegate dateFieldWillCancel:self];
    }
}

- (void)dateChanged:(id)sender
{
    if ([self.editDelegate respondsToSelector:@selector(dateFieldDidChangeDate:)]) {
        [self.editDelegate dateFieldDidChangeDate:self];
    }
}

- (UIToolbar *)doneBar
{
    if (!_doneBar) {
        _doneBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 35)];
    }
    return _doneBar;
}

- (void)setDate:(NSDate *)date
{
    [self.dateView setDate:date animated:NO];
}

- (NSDate *)date
{
    return self.dateView.date;
}

- (UIDatePicker *)dateView
{
    return (UIDatePicker *)self.inputView;
}

@end
