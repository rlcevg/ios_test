//
//  FriendsViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/18/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "FriendsViewController.h"
#import "FBRequest.h"
#import "FBSession.h"
#import "FBUtility.h"
#import "FBError.h"
#import "DataTabBarController.h"
#import "Friend.h"
#import "FriendCell.h"
#import "FBURLConnection.h"

#define FRIEND_DEFAULT_PRIOTITY 0
static NSString *defaultImageName = @"FacebookSDKResources.bundle/FBFriendPickerView/images/default.png";


@interface FriendsViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) UIImage *defaultPicture;

@end


@implementation FriendsViewController

@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (UITableView *)tableView
{
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [self.view addSubview:_tableView];
    return _tableView;
}

- (UIActivityIndicatorView *)spinner
{
    if (_spinner) {
        return _spinner;
    }
    _spinner = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.hidesWhenStopped = YES;
    // We want user to be able to scroll while we load.
    _spinner.userInteractionEnabled = NO;

    [self.tableView addSubview:_spinner];
    return _spinner;
}

- (void)loadData
{
    if (self.friends.count) {
        [self.tableView reloadData];
        return;
    }

    FBRequest *request = [FBRequest requestForGraphPath:@"me/friends"];
    request.session = FBSession.activeSession;
    NSString *pictureField = ([FBUtility isRetinaDisplay]) ? @"picture.width(100).height(100)" : @"picture";
    NSArray *fields = [NSArray arrayWithObjects:
                       @"id",
                       @"name",
                       @"first_name",
                       @"middle_name",
                       @"last_name",
                       pictureField,
                       nil];
    NSString *allFields = [FriendsViewController fieldsForRequest:fields];
    [request.parameters setObject:allFields forKey:@"fields"];

    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestCompleted:connection result:result error:error];
    }];
    [self centerAndStartSpinner];
}

+ (NSString *)fieldsForRequest:(NSArray *)fieldsArray
{
    // Start with custom fields.
    NSMutableSet *nameSet = [NSMutableSet set];
    for (NSString *name in fieldsArray) {
        [nameSet addObject:name];
    }

    // redundant...
    NSMutableArray *sortedFields = [[nameSet allObjects] mutableCopy];
    [sortedFields sortUsingSelector:@selector(caseInsensitiveCompare:)];

    // Build the comma-separated string
    NSMutableString *fields = [[NSMutableString alloc] init];

    for (NSString *field in sortedFields) {
        if ([fields length]) {
            [fields appendString:@","];
        }
        [fields appendString:field];
    }

    return fields;
}

- (void)centerAndStartSpinner
{
    [FBUtility centerView:self.spinner tableView:self.tableView];
    [self.spinner startAnimating];
}

- (void)requestCompleted:(FBRequestConnection *)connection
                  result:(id)result
                   error:(NSError *)error
{
    NSDictionary *resultDictionary = (NSDictionary *)result;

    NSArray *data = nil;
    if (!error && [result isKindOfClass:[NSDictionary class]]) {
        id rawData = [resultDictionary objectForKey:@"data"];
        if ([rawData isKindOfClass:[NSArray class]]) {
            data = (NSArray *)rawData;
        }
    }

    if (!error && !data) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[FBErrorParsedJSONResponseKey] = result;
        if (FBSession.activeSession) {
            userInfo[FBErrorSessionKey] = FBSession.activeSession;
        }
        error = [[NSError alloc] initWithDomain:FacebookSDKDomain
                                            code:FBErrorProtocolMismatch
                                        userInfo:userInfo];
    }

    if (error) {
        // Cancellation is not really an error we want to bother the delegate with.
        BOOL cancelled = [error.domain isEqualToString:FacebookSDKDomain] &&
        error.code == FBErrorOperationCancelled;

        if (cancelled) {
            [self.spinner stopAnimating];
        } else {
            [self handleError:error];
        }
    } else {
        [self addResultsAndUpdateView:resultDictionary];
    }
}

- (void)handleError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)addResultsAndUpdateView:(NSDictionary*)results
{
    NSArray *data = (NSArray *)[results objectForKey:@"data"];

    [self saveData:data];
    [self.spinner stopAnimating];
    [self updateView];
}

- (void)saveData:(NSArray *)data
{
//    NSMutableArray *friends = [NSMutableArray array];
    for (NSDictionary *obj in data) {
        Friend *friend = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Friend"
                          inManagedObjectContext:self.managedObjectContext];
        friend.uid = obj[@"id"];
        friend.firstName = obj[@"first_name"];
        friend.lastName = obj[@"last_name"];
        id picture = obj[@"picture"];
        if ([picture isKindOfClass:[NSString class]]) {
            friend.avatarUrl = picture;
        } else {
            friend.avatarUrl = [[picture objectForKey:@"data"] objectForKey:@"url"];
        }
        friend.priority = [NSNumber numberWithInt:FRIEND_DEFAULT_PRIOTITY];
//        [friends addObject:friend];
    }
    [self saveContext];
//    [friends removeAllObjects];
}

- (void)saveContext
{
    [(DataTabBarController *)self.parentViewController saveContext];
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        DataTabBarController *parentController = (DataTabBarController *)self.parentViewController;
        _managedObjectContext = parentController.managedObjectContext;
    }
    return _managedObjectContext;
}

- (void)updateView
{
    self.friends = nil;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellKey = @"fbTableCell";
    FriendCell *cell = (FriendCell*)[tableView dequeueReusableCellWithIdentifier:cellKey];

    if (!cell) {
        cell = [[FriendCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:cellKey];
    }

    Friend *friend = self.friends[indexPath.row];
    cell.picture = [self tableView:tableView imageForItem:friend];
    cell.title = friend.firstName;
    cell.titleSuffix = friend.lastName;
    cell.subtitle = nil;
    cell.priorityField.text = [friend.priority stringValue];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selected = NO;

    cell.boldTitle = YES;
    cell.boldTitleSuffix = NO;

    cell.controller = self;
    cell.friend = friend;
    cell.index = indexPath.row;

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Friend *friend = self.friends[indexPath.row];
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url;
    if ([app canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", friend.uid]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", friend.uid]];
    }
    [app openURL:url];
}

- (NSArray *)friends
{
    if (_friends) {
        return _friends;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;

    NSSortDescriptor *sortByPriority = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
    NSSortDescriptor *sortByFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortByLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
                                sortByPriority,
                                sortByFirstName,
                                sortByLastName, nil];
    fetchRequest.sortDescriptors = sortDescriptors;

    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
    }

    _friends = fetchedObjects;
    return _friends;
}

- (UIImage *)tableView:(UITableView *)tableView imageForItem:(Friend *)friend
{
    __block UIImage *image = nil;
    NSString *urlString = friend.avatarUrl;
    if (urlString) {
        FBURLConnectionHandler handler =
        ^(FBURLConnection *connection, NSError *error, NSURLResponse *response, NSData *data) {
            if (!error) {
                image = [UIImage imageWithData:data];

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.friends indexOfObject:friend] inSection:0];
                if (indexPath) {
                    FriendCell *cell = (FriendCell *)[tableView cellForRowAtIndexPath:indexPath];

                    if (cell) {
                        cell.picture = image;
                    }
                }
            }
        };

        FBURLConnection *connection = [[FBURLConnection alloc]
                                        initWithURL:[NSURL URLWithString:urlString]
                                        completionHandler:handler];
    }

    if (image) {
        return image;
    }

    return self.defaultPicture;
}

- (UIImage *)defaultPicture
{
    if (!_defaultPicture) {
        _defaultPicture = [UIImage imageNamed:defaultImageName];
    }
    return _defaultPicture;
}

@end
