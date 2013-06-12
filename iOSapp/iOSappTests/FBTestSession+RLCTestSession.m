//
//  FBTestSession+RLCTestSession.m
//  iOSapp
//
//  Created by Evgenij on 6/12/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "FBTestSession+RLCTestSession.h"
#import <FacebookSDK/FBRequest.h>
#import <FacebookSDK/FBUtility.h>

static NSString *const FBLoginTestUserID = @"id";
static NSString *const FBLoginTestUserName = @"name";

@implementation FBTestSession (RLCTestSession)

- (void)populateTestUsers:(NSArray*)users testAccounts:(NSArray*)testAccounts
{
    //    pthread_mutex_lock(&mutex);

    if (!testUsers) {
        testUsers = [[NSMutableDictionary alloc] init];
    }

    // Map user IDs to test_accounts
    for (NSDictionary *testAccount in testAccounts) {
        id uid = [[testAccount objectForKey:FBLoginTestUserID] stringValue];
        [testUsers setObject:[NSMutableDictionary dictionaryWithDictionary:testAccount]
                           forKey:uid];
    }

    // Add the user name to the test_account data.
    for (NSDictionary *user in users) {
        id uid = [[user objectForKey:@"uid"] stringValue];
        NSMutableDictionary *testUser = [testUsers objectForKey:uid];
        [testUser setObject:[user objectForKey:FBLoginTestUserName] forKey:FBLoginTestUserName];
    }

    //    pthread_mutex_unlock(&mutex);
}

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
    FBRequest *request = [[FBRequest alloc] initWithSession:nil
                                                  graphPath:@"fql"
                                                 parameters:parameters
                                                 HTTPMethod:@"get"];
    [request startWithCompletionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         NSLog(@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
//         abort();
         if (error ||
             !result) {
             [self performSelector:@selector(raiseException:) withObject:error];
         }
         id data = [result objectForKey:@"data"];
         if (![data isKindOfClass:[NSArray class]] ||
             [data count] != 2) {
             [self performSelector:@selector(raiseException:) withObject:nil];
         }

         // We get back two sets of results. The first is from the test_accounts
         // query, the second from the users query.
         id testAccounts = [[data objectAtIndex:0] objectForKey:@"fql_result_set"];
         id users = [[data objectAtIndex:1] objectForKey:@"fql_result_set"];
         if (![testAccounts isKindOfClass:[NSArray class]] ||
             ![users isKindOfClass:[NSArray class]]) {
             [self performSelector:@selector(raiseException:) withObject:nil];
         }

         // Use both sets of results to populate our static array of accounts.
         [self populateTestUsers:users testAccounts:testAccounts];

         // Now that we've populated all test users, we can continue looking for
         // the matching user, which started this all off.
         [self performSelector:@selector(findOrCreateSharedUser)];
     }];
    
}

@end
