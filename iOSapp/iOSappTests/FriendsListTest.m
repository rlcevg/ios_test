//
//  FriendsListTest.m
//  iOSapp
//
//  Created by Evgenij on 6/16/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Kiwi.h"
#import "FriendsViewController.h"


SPEC_BEGIN(FriendsViewControllerTests)

describe(@"FriendsViewController", ^{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    context(@"when instantiated", ^{
        __block FriendsViewController *viewController = nil;

        beforeEach(^{
            viewController = (FriendsViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"Friends"];
            [viewController loadView];
        });


        it(@"should have been instantiated correctly from Storyboard", ^{
            viewController = (FriendsViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"Friends"];
            [viewController shouldNotBeNil];
        });

        it(@"should be subclass of FBFriendPickerViewController", ^{
            [[viewController should] beKindOfClass:[FBFriendPickerViewController class]];
        });

        it(@"should perform action on frined selection", ^{
            [[viewController should] conformToProtocol:@protocol(FBViewControllerDelegate)];
            [[viewController should] respondToSelector:@selector(friendPickerViewControllerSelectionDidChange:)];
        });
    });
});

SPEC_END
