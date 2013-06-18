//
//  FBGraphObjectTableDataSource+PriorityField.m
//  iOSapp
//
//  Created by Evgenij on 6/17/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "FBGraphObjectTableDataSource+PriorityField.h"
#import "FBGraphObjectTableCell.h"
#import "FrTextField.h"

@implementation FBGraphObjectTableDataSource (PriorityField)

- (FBGraphObjectTableCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString * const cellKey = @"fbTableCell";
    FBGraphObjectTableCell *cell =
    (FBGraphObjectTableCell*)[tableView dequeueReusableCellWithIdentifier:cellKey];

    if (!cell) {
        cell = [[FBGraphObjectTableCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:cellKey];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        FrTextField *textField = [[FrTextField alloc] initWithFrame:CGRectMake(0, 8, 40, 30)];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.borderStyle = UITextBorderStyleBezel;
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tableView = tableView;
        cell.accessoryView = textField;
    }

    return cell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

- (BOOL)textFieldShouldReturn:(FrTextField *)textField
{
//    [textField.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:[items count] - 1 inSection:1]];
    
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return textField.text.length + string.length <= 1;
}

@end
