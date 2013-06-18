//
//  FriendCell.m
//  iOSapp
//
//  Created by Evgenij on 6/18/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "FriendCell.h"


@interface FriendCell ()

@property (strong, nonatomic) NSString *undoText;

@end


@implementation FriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 8, 40, 30)];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.borderStyle = UITextBorderStyleBezel;
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        self.accessoryView = self.priorityField = textField;

        UIToolbar *doneBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 35)];
        doneBar.barStyle = UIBarStyleBlack;
        doneBar.translucent = YES;
        [doneBar setAlpha:0.5];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //Add buttons to the array
        NSArray *items = [NSArray arrayWithObjects:doneBtn, flexItem, cancelBtn, nil];
        [doneBar setItems:items animated:NO];
        textField.inputAccessoryView = doneBar;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Priority field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.controller.activeField == nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.controller.activeField = textField;
    self.controller.index = self.index;
    self.undoText = textField.text;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.controller.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.controller updateView];
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length + string.length > 1)
        return NO;
    NSCharacterSet *unacceptedInput = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] <= 1);
}

- (void)cancel:(id)sender
{
    UITextField *textField = self.controller.activeField;
    textField.text = self.undoText;
    [textField resignFirstResponder];
}

- (void)done:(id)sender
{
    UITextField *textField = self.controller.activeField;
    if (textField.text.length == 0) {
        textField.text = self.undoText;
    }
    FriendCell *cell = (FriendCell *)self.controller.activeField.superview;
    cell.friend.priority = [NSNumber numberWithInt:[textField.text integerValue]];
    [self.controller saveContext];
    [self.controller updateView];
    [textField resignFirstResponder];
}

@end
