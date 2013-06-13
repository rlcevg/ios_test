//
//  RLCTextView.m
//  iOSapp
//
//  Created by Evgenij on 6/13/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "RLCTextView.h"
#import "RLCTextViewDelegate.h"

@interface RLCTextView ()

@property (strong, nonatomic, readonly) UIToolbar *doneBar;

@end

@implementation RLCTextView

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
    self.font = [UIFont fontWithName:@"Arial" size:15.0];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];

    UIToolbar *doneBar = self.doneBar;
    doneBar.barStyle = UIBarStyleBlack;
    doneBar.translucent = YES;
    [doneBar setAlpha:0.5];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)];
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSave)];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //Add buttons to the array
    NSArray *items = [NSArray arrayWithObjects:saveBtn, flexItem, cancelBtn, nil];
    [doneBar setItems:items animated:NO];
}

- (UIToolbar *)doneBar
{
    if (!_doneBar) {
        _doneBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    }
    return _doneBar;
}

- (void)setEditing:(BOOL)editing
{
    if (editing && !_editing) {
        self.inputAccessoryView = self.doneBar;
    } else if (!editing && _editing) {
        [self resignFirstResponder];
        self.inputAccessoryView = nil;
    }
    _editing = editing;
}

- (void)onSave
{
    if ([self.editDelegate respondsToSelector:@selector(textViewOnSave:)]) {
        [self.editDelegate textViewOnSave:self];
    }
}

- (void)onCancel
{
    if ([self.editDelegate respondsToSelector:@selector(textViewOnCancel:)]) {
        [self.editDelegate textViewOnCancel:self];
    }
}

@end
