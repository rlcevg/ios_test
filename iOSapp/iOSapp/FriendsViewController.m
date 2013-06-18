//
//  FriendsViewController.m
//  iOSapp
//
//  Created by Evgenij on 6/15/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "FriendsViewController.h"
#import "FBRequest.h"
#import "FBGraphObjectTableDataSource.h"
#import "Friend.h"
#import "DataTabBarController.h"
#import "RLCAppDelegate.h"
#import "FBGraphObjectPagingLoader.h"
#import "FBGraphObjectTableCell.h"
#import "FBGraphObjectTableDataSource+PriorityField.h"
#import "FBUtility.h"

#define FRIEND_DEFAULT_PRIORITY 0


@interface FriendsViewController ()

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) NSSet *priorities;
@property (strong, nonatomic) NSNumber *activePriority;
@property (strong, nonatomic, readonly) NSArray *friends;
@property (assign, nonatomic) BOOL dataLoaded;
@property (strong, atomic, readonly) NSManagedObjectContext *backgroundManagedObjectContext;

@end


@implementation FriendsViewController

@synthesize managedObjectContext = _managedObjectContext,
            backgroundManagedObjectContext = _backgroundManagedObjectContext;

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
    self.delegate = self;
    self.allowsMultipleSelection = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Next code is according to ios-sdk-tutorial/show-friends/
// Do we really need it?
- (void)dealloc
{
    self.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.friends.count == 0) {
        [self loadData];
        self.dataLoaded = NO;
    } else {
        [self loadSavedData];
    }
    [self clearSelection];
}

- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker
{
    if (friendPicker.selection.count) {
        id<FBGraphUser> friend = friendPicker.selection[0];
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *url;
        if ([app canOpenURL:[NSURL URLWithString:@"fb://"]]) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", friend[@"id"]]];
        } else {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", friend[@"id"]]];
        }
        [app openURL:url];
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        DataTabBarController *parentController = (DataTabBarController *)self.parentViewController;
        _managedObjectContext = parentController.managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSSet *)priorities
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];

    fetchRequest.entity = entity;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"priority"]];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.resultType = NSDictionaryResultType;

    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
    }

    return [NSSet setWithArray:fetchedObjects];
}

- (NSSet *)friendsWithProirity:(NSNumber *)priority
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"priority == %i", priority];

    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
    }

    return [NSSet setWithArray:fetchedObjects];
}

- (NSArray *)friends
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
    }

    return fetchedObjects;
}

- (void)loadSavedData
{

}

//- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user
//{
//    NSManagedObjectContext *context = self.managedObjectContext;
//    Friend *friend = [NSEntityDescription
//                      insertNewObjectForEntityForName:@"Friend"
//                      inManagedObjectContext:context];
//    friend.uid = user.id;
//    friend.priority = FRIEND_DEFAULT_PRIORITY;
//    friend.firstName = user.first_name;
//    friend.lastName = user.last_name;
//    friend.avatarUrl = user[@"picture"];
//    return YES;
//}

- (void)saveContext
{
    [(DataTabBarController *)self.parentViewController saveContext];
}

//- (void)pagingLoaderDidFinishLoading:(FBGraphObjectPagingLoader *)pagingLoader
//{
//    if ([super respondsToSelector:@selector(pagingLoaderDidFinishLoading:)]) {
//        [super performSelector:@selector(pagingLoaderDidFinishLoading:) withObject:pagingLoader];
//    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//    });
//}

- (NSManagedObjectContext *)backgroundManagedObjectContext
{
    if (!_backgroundManagedObjectContext) {
        RLCAppDelegate *app = UIApplication.sharedApplication.delegate;
        NSPersistentStoreCoordinator *coordinator = [app persistentStoreCoordinator];
        if (coordinator != nil) {
            _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] init];
            [_backgroundManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _backgroundManagedObjectContext;
}

- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker
{
    if ([self valueForKeyPath:@"loader.nextLink"]) {
        return;
    }
//    self.dataLoaded = YES;
    // Save loaded data to database in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *cells = [NSMutableArray array];
        for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j) {
            for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i) {
                [cells addObject:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
            }
        }
        for (FBGraphObjectTableCell *cell in cells)
        {
//            UITextField *textField = [cell textField];
//            NSLog(@"%@"; [textField text]);
        }

        NSError *error;
        if (![self.backgroundManagedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    });
}

- (FBRequest*)requestForLoadData {

    // Respect user settings in case they have changed.
    NSMutableArray *sortFields = [NSMutableArray array];
    [sortFields addObject:@"first_name"];
    [sortFields addObject:@"middle_name"];
    [sortFields addObject:@"last_name"];
    FBGraphObjectTableDataSource *dataSource = (FBGraphObjectTableDataSource *)[(id)self dataSource];
    [dataSource setSortingByFields:sortFields ascending:YES];
    dataSource.groupByField = @"priority";
    dataSource.useCollation = YES;

    // me or one of my friends that also uses the app
    NSString *user = self.userID;
    if (!user) {
        user = @"me";
    }

    // create the request and start the loader
    FBRequest *request = [FriendsViewController requestWithUserID:user
                                                                  fields:self.fieldsForRequest
                                                              dataSource:dataSource
                                                                 session:self.session];
    return request;
}

+ (FBRequest *)requestWithUserID:(NSString*)userID
                         fields:(NSSet*)fields
                     dataSource:(FBGraphObjectTableDataSource*)datasource
                        session:(FBSession*)session {

    FBRequest *request = [FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@/friends", userID]];
    [request setSession:session];

    // Use field expansion to fetch a 100px wide picture if we're on a retina device.
    NSString *pictureField = ([FBUtility isRetinaDisplay]) ? @"picture.width(100).height(100)" : @"picture";

    NSString *allFields = [datasource fieldsForRequestIncluding:fields,
                           @"id",
                           @"name",
                           @"first_name",
                           @"middle_name",
                           @"last_name",
                           pictureField,
                           nil];
    [request.parameters setObject:allFields forKey:@"fields"];

    return request;
}

@end
