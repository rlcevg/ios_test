//
//  FriendsListTest.m
//  iOSapp
//
//  Created by Evgenij on 6/16/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Kiwi.h"
#import "FriendsViewController.h"
#import "CoreData+MagicalRecord.h"
#import "Friend.h"
#import "DataTabBarController.h"
#import "FriendCell.h"


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
            [[viewController should] beMemberOfClass:[FriendsViewController class]];
        });

        it(@"should perform action on frined selection", ^{
            [[viewController should] conformToProtocol:@protocol(UITableViewDelegate)];
            [[viewController should] respondToSelector:@selector(tableView:didSelectRowAtIndexPath:)];
        });

        it(@"should operate with priority", ^{
            [MagicalRecord setupCoreDataStackWithInMemoryStore];
            NSMutableArray *friends = [NSMutableArray array];
            for (int i = 0; i < 5; i++) {
                Friend *friend = [Friend MR_createEntity];
                friend.firstName = [NSString stringWithFormat:@"First Name%i", i ];
                friend.lastName = [NSString stringWithFormat:@"Last Name%i", i];
                friend.priority = 0;
                [friends addObject:friend];
            }
            [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

            DataTabBarController *parentController = (DataTabBarController *)[storyBoard instantiateViewControllerWithIdentifier:@"DataTabBar"];
            parentController.managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            viewController = parentController.viewControllers[3];
            [viewController view];

            UITableView *tableView = [viewController valueForKey:@"tableView"];
            [tableView shouldNotBeNil];
            [[theValue(tableView.visibleCells.count) should] equal:theValue(5)];

            FriendCell *cell;
            NSArray *cells = tableView.visibleCells;
            cell = (FriendCell *)cells[0];
            [[cell.friend.firstName should] equal:@"First Name0"];
            cell = (FriendCell *)cells[1];
            [[cell.friend.firstName should] equal:@"First Name1"];
            cell = (FriendCell *)cells[2];
            [[cell.friend.firstName should] equal:@"First Name2"];

            cell = (FriendCell *)cells[2];
            cell.friend.priority = [NSNumber numberWithInt:5];
            cell = (FriendCell *)cells[3];
            cell.friend.priority = [NSNumber numberWithInt:5];
            cell = (FriendCell *)cells[4];
            cell.friend.priority = [NSNumber numberWithInt:6];
            [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
            [viewController updateView];

            cells = tableView.visibleCells;
            cell = (FriendCell *)cells[0];
            [[cell.friend.firstName should] equal:@"First Name4"];
            cell = (FriendCell *)cells[1];
            [[cell.friend.firstName should] equal:@"First Name2"];
            cell = (FriendCell *)cells[2];
            [[cell.friend.firstName should] equal:@"First Name3"];

            [MagicalRecord cleanUp];
        });
    });
});

SPEC_END
