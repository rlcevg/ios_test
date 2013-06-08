//
//  FacebookAuthTests.m
//  iOSapp
//
//  Created by Evgenij on 6/8/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Kiwi.h"

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

        context(@"should have a field to enter User Name that", ^{
            it(@"exists and is called userName", ^{
                [[viewController.userName should] beKindOfClass:[UITextField class]];
            });
        });

        context(@"should have a field to enter Password that", ^{
            it(@"exists and is called password", ^{
                [[viewController.password should] beKindOfClass:[UITextField class]];
            });
            it(@"is secure", ^{
                [[theValue(viewController.password.secureTextEntry) should] equal:theValue(YES)];
            });
        });

        context(@"should have a button that", ^{
            it(@"exists and called signinButton", ^{
                [[viewController.signinButton should] beKindOfClass:[UIButton class]];
            });

            it(@"has a target of the view controller and an action of signin:", ^{
                NSArray *actions = [viewController.signinButton actionsForTarget:viewController forControlEvent:UIControlEventTouchUpInside];
                [actions shouldNotBeNil];
                [[theValue([actions indexOfObject:@"signin:"]) shouldNot] equal:theValue(NSNotFound)];
            });
		});

        context(@"should have methods for the signin button that", ^{
            it(@"responds to signin", ^{
                [[viewController should] respondsToSelector:@selector(signin:)];
            });

            it(@"saves username, password, authkey and expiry into NSUserDefaults", ^{

				[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userName"];
				[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"authKey"];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"Expiry"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                viewController.userName.text = @"ios-testuser";
                viewController.password.text = @"xxx";
                [viewController signin:viewController.signinButton];

				// check also authKey and Expiry
                [[theValue([[NSUserDefaults standardUserDefaults] stringForKey:@"userName"]) should] equal:theValue(@"ios-testuser")];
                [[theValue([[NSUserDefaults standardUserDefaults] stringForKey:@"password"]) should] equal:theValue(@"xxx")];
                [[theValue([[[NSUserDefaults standardUserDefaults] stringForKey:@"authKey"] length]) shouldNot] equal:theValue(0)];
				[theValue([[NSUserDefaults standardUserDefaults] objectForKey:@"Expiry"]) shouldNotBeNil];

            });

        });
    });
});

SPEC_END
