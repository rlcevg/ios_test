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

#define FRIEND_DEFAULT_PRIORITY 0


@interface FriendsViewController ()

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) NSSet *priorities;
@property (strong, nonatomic) NSNumber *activePriority;

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
    [self loadData];
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
/*
- (void)retrieveTestUsersForApp
{
    // We need three pieces of data: id, access_token, and name (which we use to
    // encode permissions). We get access_token from the test_account FQL table and
    // name from the user table; they share an id. Use FQL multiquery to get it all
    // in one go.
    NSString *testAccountQuery = [NSString stringWithFormat:
                                  @"SELECT id,access_token FROM test_account WHERE app_id = %@",
                                  self.testAppID];
    NSString *userQuery = @"SELECT uid,name FROM user WHERE uid IN (SELECT id FROM #test_accounts)";
    NSDictionary *multiquery = [NSDictionary dictionaryWithObjectsAndKeys:
                                testAccountQuery, @"test_accounts",
                                userQuery, @"users",
                                nil];

    NSString *jsonMultiquery = [FBUtility simpleJSONEncode:multiquery];

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                jsonMultiquery, @"q",
                                self.appAccessToken, @"access_token",
                                nil];
    FBRequest *request = [[[FBRequest alloc] initWithSession:nil
                                                   graphPath:@"fql"
                                                  parameters:parameters
                                                  HTTPMethod:nil]
                          autorelease];
    [request startWithCompletionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error ||
             !result) {
             [self raiseException:error];
         }
         id data = [result objectForKey:@"data"];
         if (![data isKindOfClass:[NSArray class]] ||
             [data count] != 2) {
             [self raiseException:nil];
         }

         // We get back two sets of results. The first is from the test_accounts
         // query, the second from the users query.
         id testAccounts = [[data objectAtIndex:0] objectForKey:@"fql_result_set"];
         id users = [[data objectAtIndex:1] objectForKey:@"fql_result_set"];
         if (![testAccounts isKindOfClass:[NSArray class]] ||
             ![users isKindOfClass:[NSArray class]]) {
             [self raiseException:nil];
         }

         // Use both sets of results to populate our static array of accounts.
         [self populateTestUsers:users testAccounts:testAccounts];

         // Now that we've populated all test users, we can continue looking for
         // the matching user, which started this all off.
         [self findOrCreateSharedUser];
     }];
    
}
*/

- (FBRequest*)requestForLoadData
{
    if (!self.activePriority) {
        self.activePriority = [NSNumber numberWithInt:FRIEND_DEFAULT_PRIORITY];
    }
    // Respect user settings in case they have changed.
    NSMutableArray *sortFields = [NSMutableArray array];
    NSString *groupByField = nil;
    if (self.sortOrdering == FBFriendSortByFirstName) {
        [sortFields addObject:@"first_name"];
        [sortFields addObject:@"middle_name"];
        [sortFields addObject:@"last_name"];
        groupByField = @"first_name";
    } else {
        [sortFields addObject:@"last_name"];
        [sortFields addObject:@"first_name"];
        [sortFields addObject:@"middle_name"];
        groupByField = @"last_name";
    }
    FBGraphObjectTableDataSource *dataSource = [(id)self dataSource];
//    [self.dataSource setSortingByFields:sortFields ascending:YES];
//    self.dataSource.groupByField = groupByField;
//    self.dataSource.useCollation = YES;

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

+ (FBRequest*)requestWithUserID:(NSString*)userID
                         fields:(NSSet*)fields
                     dataSource:(FBGraphObjectTableDataSource*)datasource
                        session:(FBSession*)session
{
    FBRequest *request = [FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@/friends", userID]];
    [request setSession:session];

    NSString *allFields = [datasource fieldsForRequestIncluding:fields,
                           @"id",
                           @"name",
                           @"first_name",
                           @"middle_name",
                           @"last_name",
                           @"picture",
                           nil];
    [request.parameters setObject:allFields forKey:@"fields"];


//    NSString *testAccountQuery = [NSString stringWithFormat:
//                                  @"SELECT id,access_token FROM test_account WHERE app_id = %@",
//                                  self.testAppID];
//    NSString *userQuery = @"SELECT uid,name FROM user WHERE uid IN (SELECT id FROM #test_accounts)";
//    NSDictionary *multiquery = [NSDictionary dictionaryWithObjectsAndKeys:
//                                testAccountQuery, @"test_accounts",
//                                userQuery, @"users",
//                                nil];
//
//    NSString *jsonMultiquery = [FBUtility simpleJSONEncode:multiquery];
//
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
//                                jsonMultiquery, @"q",
//                                self.appAccessToken, @"access_token",
//                                nil];
//    FBRequest *request = [[[FBRequest alloc] initWithSession:nil
//                                                   graphPath:@"fql"
//                                                  parameters:parameters
//                                                  HTTPMethod:nil]

    return request;
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

@end
