//
//  ContactsViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/4/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "ContactsViewController.h"
#import "Person.h"
#import "Contact.h"
#import "ContactCell.h"
#import "RLCAppDelegate.h"


@interface ContactsViewController ()

@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) Person *person;
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) UITextField *responder;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation ContactsViewController

@synthesize managedObjectContext = _managedObjectContext;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                       target:self
                                                       action:@selector(insertNewContact:)];
    self.navigation.rightBarButtonItem = addButton;
    self.navigation.leftBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = YES;
}

- (void)insertNewContact:(id)sender
{
    [self.tableView beginUpdates];
    Contact *contact = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Contact"
                        inManagedObjectContext:self.managedObjectContext];
    [self.person addContactsObject:contact];
    [self saveContext];

    [self.contacts insertObject:contact atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        RLCAppDelegate *appDelegate = (RLCAppDelegate *)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (void)saveContext
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - DataTab protocol

- (void)prepareData:(Person *)person
{
    self.person = person;
    self.contacts = [NSMutableArray arrayWithArray:[person.contacts allObjects]];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)configureCell:(ContactCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact = self.contacts[indexPath.row];
    cell.typeText.text = contact.type;
    cell.typeText.delegate = self;
    cell.contactText.text = contact.contact;
    cell.contactText.delegate = self;
    cell.contact = contact;
}

#pragma mark - UITableViewDataSource protocol

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Contacts";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.person removeContactsObject:self.contacts[indexPath.row]];
        [self.contacts removeObjectAtIndex:indexPath.row];
        [self saveContext];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

#pragma mark - UITextFieldDelegate protocol

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return !self.tableView.editing && !self.responder;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.responder = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.responder = nil;
    ContactCell *cell = (ContactCell *)textField.superview.superview;
    switch (textField.tag) {
        case 1001:
            cell.contact.type = textField.text;
            break;
        case 1002:
            cell.contact.contact = textField.text;
            break;
        default:
            break;
    }
    [self saveContext];
    return NO;
}

#define ALPHA                   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define NUMERIC                 @"1234567890"
#define ALPHA_NUMERIC           ALPHA NUMERIC

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *unacceptedInput = nil;
    switch (textField.tag) {
        case 1001:
            if (textField.text.length + string.length > 5) {
                return NO;
            }
            unacceptedInput = [[NSCharacterSet letterCharacterSet] invertedSet];
            break;
        case 1002:
            if ([[textField.text componentsSeparatedByString:@"@"] count] > 1)
                unacceptedInput = [[NSCharacterSet characterSetWithCharactersInString:[ALPHA_NUMERIC stringByAppendingString:@".-"]] invertedSet];
            else
                unacceptedInput = [[NSCharacterSet characterSetWithCharactersInString:[ALPHA_NUMERIC stringByAppendingString:@".!#$%&'*+-/=?^_`{|}~@"]] invertedSet];
            break;
        default:
            unacceptedInput = [[NSCharacterSet illegalCharacterSet] invertedSet];
            break;
    }
    return ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] <= 1);
}

@end
