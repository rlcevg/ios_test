//
//  FacebookAuthTests.m
//  iOSapp
//
//  Created by Evgenij on 6/8/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Kiwi.h"
#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ProfileViewController.h"
//#import <FacebookSDK/FBTestSession.h>
#import "DataTabBarController.h"
#import "RLCAppDelegate.h"
#import "FBTestSession+RLCTestSession.h"

SPEC_BEGIN(LoginViewControllerTests)

describe(@"LoginViewController", ^{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    context(@"when instantiated", ^{
        __block LoginViewController *viewController = nil;

        beforeEach(^{
            viewController = (LoginViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"Login"];
            [viewController loadView];
        });


        it(@"should have been instantiated correctly from Storyboard", ^{
            viewController = (LoginViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"Login"];
            [viewController shouldNotBeNil];
        });

        it(@"should be first visible view", ^{
            UINavigationController *navController = [storyBoard instantiateInitialViewController];
            [[navController.topViewController should] beMemberOfClass:[viewController class]];
            [[navController.visibleViewController should] equal:navController.topViewController];
        });

        context(@"should have a magic login button", ^{
            it(@"exists and is called fbLoginView", ^{
                NSLog(@"a");
                [[viewController.fbLoginView should] beKindOfClass:[FBLoginView class]];
            });

            it(@"has a delegate and responds to login methods", ^{
                id delegate = viewController.fbLoginView.delegate;
                [delegate shouldNotBeNil];
                [[delegate should] equal:viewController];
                [[delegate should] respondToSelector:@selector(loginViewShowingLoggedInUser:)];
                [[delegate should] respondToSelector:@selector(loginView:handleError:)];
            });

            xit(@"is a black box and we dont want to get into FBLoginView implementation", NULL);
        });
    });
});

SPEC_END

SPEC_BEGIN(ProfileViewControllerAuthTests)

describe(@"ProfileViewController", ^{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    context(@"when instantiated", ^{
        __block ProfileViewController *viewController = nil;
        __block NSManagedObjectContext *managedObjectContext;

        beforeAll(^{
            RLCAppDelegate *appDelegate = [[RLCAppDelegate alloc] init];
            NSURL *storeURL = [[appDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:@"iOSapp.sqlite"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
                [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
            }
            managedObjectContext = appDelegate.managedObjectContext;
        });

        beforeEach(^{
            viewController = (ProfileViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"Profile"];
            [viewController loadView];
        });

        // Fails with blocks on blocks by blocks and over blocks... too many threading
        xit(@"should load user's info", ^{
            DataTabBarController *dataTab = (DataTabBarController *)[storyBoard instantiateViewControllerWithIdentifier:@"DataTabBar"];
            dataTab.managedObjectContext = managedObjectContext;
            viewController = dataTab.viewControllers[0];
            [viewController prepareData:dataTab.person];
            [viewController view];

            [[viewController.nameLabel.text should] equal:@"Евгений"];

            __block bool blockFinished = NO;
            FBTestSession *fbSession = [FBTestSession sessionWithSharedUserWithPermissions:@[@"user_birthday", @"user_about_me", @"email"]];
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

            // Run loop
            NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
            while (blockFinished == NO && [loopUntil timeIntervalSinceNow] > 0) {
//                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                                         beforeDate:loopUntil];
                sleep(0.1);
            }

            [[theValue(FBSession.activeSession.isOpen) should] equal:@YES];
            [dataTab reloadData];
            [[viewController.nameLabel.text should] equal:@"Mary"];
        });

        context(@"should have a magic logout button", ^{
            it(@"exists and is called fbLoginView", ^{
                NSLog(@"a");
                [[viewController.fbLoginView should] beKindOfClass:[FBLoginView class]];
            });

            it(@"has a delegate and responds to logout methods", ^{
                id delegate = viewController.fbLoginView.delegate;
                [delegate shouldNotBeNil];
                [[delegate should] equal:viewController];
                [[delegate should] respondToSelector:@selector(loginViewShowingLoggedOutUser:)];
                [[delegate should] respondToSelector:@selector(loginView:handleError:)];
            });

            xit(@"is a black box and we dont want to get into FBLoginView implementation", NULL);
        });
    });
});

SPEC_END
