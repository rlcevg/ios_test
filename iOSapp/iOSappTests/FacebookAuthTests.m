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

SPEC_BEGIN(LoginViewControllerTests)

describe(@"LoginViewController", ^{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    context(@"when instantiated", ^{
        __block LoginViewController *viewController = nil;

        beforeEach(^{
            viewController = (LoginViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"Login"];
            [viewController loadView];
        });


        it(@"should have been instantiated correctly from Storyboard", ^{
            viewController = (LoginViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"Login"];
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
