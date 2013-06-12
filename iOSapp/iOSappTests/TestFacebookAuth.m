//
//  TestFacebookAuth.m
//  iOSapp
//
//  Created by Evgenij on 6/12/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "TestFacebookAuth.h"
#import "FBTestSession+RLCTestSession.h"
#import <FacebookSDK/FBRequest.h>

@implementation TestFacebookAuth

- (void)testAuth
{
    __block bool blockFinished = NO;
    //            FBTestSession *fbSession = [FBTestSession sessionWithSharedUserWithPermissions:@[@"user_birthday", @"user_about_me", @"email"]];
    FBTestSession *fbSession = [FBTestSession sessionWithSharedUserWithPermissions:@[@"email"]];
    [fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        NSLog(@"session %@, status %d, error %@", session, status, error);
        [FBSession setActiveSession:session];
        FBRequest *me = [FBRequest requestForMe];
        NSLog(@"me request %@", me);
        [me startWithCompletionHandler: ^(FBRequestConnection *connection,
                                          NSDictionary<FBGraphUser> *my,
                                          NSError *error) {
            //                    STAssertNotNil(my.id, @"id shouldn't be nil");

            blockFinished = YES;
        }];
    }];
    sleep(5.0);

    //            [fbSession performSelector:@selector(retrieveTestUsersForApp)];
    NSLog(@"%@", fbSession.testUserID);
    for (NSDictionary *user in testUsers) {
        NSLog(@"%@ - %@", user[@"id"], user[@"name"]);
    }

    // Run loop
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (blockFinished == NO && [loopUntil timeIntervalSinceNow] > 0) {
        //                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
        //                                         beforeDate:loopUntil];
        sleep(0.1);
    }

    STAssertTrue(FBSession.activeSession.isOpen, @"Session should be open");
}

@end
