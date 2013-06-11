//
//  iOSappTests.m
//  iOSappTests
//
//  Created by Evgenij on 6/4/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Kiwi.h"
#import "CoreData+MagicalRecord.h"
#import "Person.h"
#import "DataTabBarController.h"
#import "ProfileViewController.h"
#import "BioViewController.h"
#import "ContactsViewController.h"
#import "RLCAppDelegate.h"

#pragma mark - StorageSpec

SPEC_BEGIN(StorageSpec)

describe(@"PersonEntity", ^{
    it(@"should create a new object", ^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
        Person *person = [Person MR_createEntity];

        [person shouldNotBeNil];
        [person.name shouldBeNil];
        [person.surname shouldBeNil];
        [person.bio shouldBeNil];
        [person.photo shouldBeNil];
        [person.contacts shouldNotBeNil];
        [MagicalRecord cleanUp];
    });

    it(@"should have preloaded data", ^{
        RLCAppDelegate *appDelegate = [[RLCAppDelegate alloc] init];

        // Remove iOSapp.sqlite
        NSURL *storeURL = [[appDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:@"iOSapp.sqlite"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        }

        // Get Person data
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:appDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *people = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        [[theValue([people count]) should] equal:theValue(1)];

        Person *person = people[0];
        [[person.name should] equal:@"Евгений"];
        [[person.surname should] equal:@"surЕвгений"];
        [[person.bio should] startWithString:@"По снегам ли зимой иль по хляби осенней"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/mm/yyyy"];
        NSDate *date = [dateFormat dateFromString:@"01/01/1970"];
        [[person.birthdate should] equal:date];
        [person.photo shouldNotBeNil];
        [[person.photo should] beMemberOfClass:[UIImage class]];
        [[theValue([person.contacts count]) should] equal:theValue(3)];
    });
});

SPEC_END

#pragma mark - DataTabBarController

SPEC_BEGIN(DataTabBarControllerTest)

describe(@"DataTabBarController", ^{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    __block DataTabBarController *dataTab;
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
        dataTab = (DataTabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"DataTabBar"];
    });

    afterEach(^{
        dataTab = nil;
    });

    context(@"when controller instantiated", ^{
        it(@"is not nil", ^{
            [dataTab shouldNotBeNil];
        });

        it(@"has several child view controllers", ^{
            [[theValue([dataTab.viewControllers count]) should] equal:theValue(3)];
        });

        it(@"has strict tab order", ^{
            [[dataTab.viewControllers[0] should] beMemberOfClass:[ProfileViewController class]];
            [[dataTab.viewControllers[1] should] beMemberOfClass:[BioViewController class]];
            [[dataTab.viewControllers[2] should] beMemberOfClass:[ContactsViewController class]];
        });

        it(@"loads person data", ^{
            dataTab.managedObjectContext = managedObjectContext;
            [dataTab.managedObjectContext shouldNotBeNil];
            [[dataTab valueForKey:@"_person"] shouldBeNil];
            Person *person = dataTab.person;
            [[dataTab valueForKey:@"_person"] shouldNotBeNil];
            [[person.name should] equal:@"Евгений"];
        });

        it(@"should not create managedObjectContext", ^{
            [dataTab.managedObjectContext shouldBeNil];
        });

        it(@"has delegate member", ^{
            id delegate = dataTab.delegate;
            [delegate shouldBeNil];

            dataTab.managedObjectContext = managedObjectContext;
            [[theValue([dataTab isViewLoaded]) should] equal:@NO];
            [dataTab view];
            [[theValue([dataTab isViewLoaded]) should] equal:@YES];
            delegate = dataTab.delegate;
            [delegate shouldNotBeNil];
            [[delegate should] equal:dataTab];
        });
    });

    context(@"when controller perform actions", ^{
        it(@"sets data on tab bar tap", ^{
            dataTab.managedObjectContext = managedObjectContext;

            [[dataTab.viewControllers[0] valueForKey:@"_person"] shouldBeNil];
            [dataTab tabBarController:dataTab shouldSelectViewController:dataTab.viewControllers[0]];
            [[[dataTab.viewControllers[0] valueForKey:@"_person"] should] equal:dataTab.person];

            [[dataTab.viewControllers[1] valueForKey:@"_person"] shouldBeNil];
            [dataTab tabBarController:dataTab shouldSelectViewController:dataTab.viewControllers[1]];
            [[[dataTab.viewControllers[1] valueForKey:@"_person"] should] equal:dataTab.person];

            [[dataTab.viewControllers[2] valueForKey:@"_contacts"] shouldBeNil];
            [dataTab tabBarController:dataTab shouldSelectViewController:dataTab.viewControllers[2]];
            [[dataTab.viewControllers[2] valueForKey:@"_contacts"] shouldNotBeNil];
        });
    });
});

SPEC_END

#pragma mark - RLCAppDelegate

SPEC_BEGIN(RLCAppDelegateTest)

describe(@"RLCAppDelegate", ^{
    context(@"at startup", ^{
        it(@"should initialize Core Data Stack", ^{
            RLCAppDelegate *appDelegate = [[RLCAppDelegate alloc] init];
            [[appDelegate should] respondToSelector:@selector(managedObjectContext)];
            [[appDelegate valueForKey:@"_managedObjectContext"] shouldBeNil];
            [appDelegate.managedObjectContext shouldNotBeNil];
            [[appDelegate valueForKey:@"_managedObjectContext"] shouldNotBeNil];
        });
    });
});

SPEC_END

#pragma mark - ProfileViewController

SPEC_BEGIN(ProfileViewControllerTest)

describe(@"ProfileViewController", ^{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    __block ProfileViewController *profile;
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
        profile = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"Profile"];
    });

    afterEach(^{
        profile = nil;
    });

    context(@"at startup", ^{
        it(@"has outlets", ^{
            [profile view];
            [[profile.photoView should] beMemberOfClass:[UIImageView class]];
            [[profile.nameLabel should] beMemberOfClass:[UILabel class]];
            [[profile.surnameLabel should] beMemberOfClass:[UILabel class]];
            [[profile.birthdateLabel should] beMemberOfClass:[UILabel class]];
            [[profile.textContainer should] beMemberOfClass:[UIView class]];
            [[profile.nameLabel.text should] equal:@"Loading..."];
            [[profile.surnameLabel.text should] equal:@"Loading..."];
            [[profile.birthdateLabel.text should] equal:@"Loading..."];
        });

        it(@"has no person data", ^{
            [[profile valueForKey:@"_person"] shouldBeNil];
        });

        it(@"presents person's profile data", ^{
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            NSArray *people = [managedObjectContext executeFetchRequest:fetchRequest error:nil];

            Person *person = people[0];
            [profile prepareData:person];
            [profile view];
            [[profile.nameLabel.text should] equal:person.name];
            [[profile.surnameLabel.text should] equal:person.surname];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [[profile.birthdateLabel.text should] equal:[dateFormatter stringFromDate:person.birthdate]];
        });
    });

    context(@"when orientation changes", ^{
        it(@"has portrait layout", ^{
            [profile view];
            UIInterfaceOrientation toInterfaceOrientation = UIInterfaceOrientationPortrait;
            UIDevice* device = [UIDevice currentDevice];
            SEL message = NSSelectorFromString(@"setOrientation:");
            if ([device respondsToSelector: message]) {
                NSMethodSignature* signature = [UIDevice instanceMethodSignatureForSelector: message];
                NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
                [invocation setTarget: device];
                [invocation setSelector: message];
                [invocation setArgument: &toInterfaceOrientation atIndex: 2];
                [invocation invoke];
            }
            [profile didRotateFromInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
            [[theValue(UIInterfaceOrientationIsPortrait(profile.interfaceOrientation)) should] equal:@YES];
            [[theValue(profile.photoContainer.center) should] equal:theValue(CGPointMake(160.0f, 84.0f))];
            [[theValue(profile.textContainer.center) should] equal:theValue(CGPointMake(160.0f, 239.0f))];
            [[theValue(profile.fbLoginView.center) should] equal:theValue(CGPointMake(160.0f, 368.0f))];
        });

        it(@"has landscape layout", ^{
            [profile view];
            UIInterfaceOrientation toInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            UIDevice* device = [UIDevice currentDevice];
            SEL message = NSSelectorFromString(@"setOrientation:");
            if ([device respondsToSelector: message]) {
                NSMethodSignature* signature = [UIDevice instanceMethodSignatureForSelector: message];
                NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
                [invocation setTarget: device];
                [invocation setSelector: message];
                [invocation setArgument: &toInterfaceOrientation atIndex: 2];
                [invocation invoke];
            }
            [profile didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];
            [[theValue(UIInterfaceOrientationIsLandscape(profile.interfaceOrientation)) should] equal:@YES];
            [[theValue(profile.photoContainer.center) should] equal:theValue(CGPointMake(95.0f, 84.0f))];
            [[theValue(profile.textContainer.center) should] equal:theValue(CGPointMake(320.0f, 103.0f))];
            [[theValue(profile.fbLoginView.center) should] equal:theValue(CGPointMake(96.0f, 210.0f))];
        });
    });
});

SPEC_END

#pragma mark - BioViewController

SPEC_BEGIN(BioViewControllerTest)

describe(@"BioViewController", ^{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    __block BioViewController *bio;

    beforeEach(^{
        bio = (BioViewController *)[storyboard instantiateViewControllerWithIdentifier:@"Bio"];
    });

    afterEach(^{
        bio = nil;
    });

    context(@"at startup", ^{
        it(@"has outlets", ^{
            [bio view];
            [[bio.bioText should] beMemberOfClass:[UITextView class]];
        });

        it(@"has no person data", ^{
            [[bio valueForKey:@"_person"] shouldBeNil];
        });

        it(@"presents person's bio data", ^{
            [MagicalRecord setupCoreDataStack];
            Person *person = [Person MR_findAll][0];
            [bio prepareData:person];
            [bio view];
            [[bio.bioText.text should] equal:person.bio];
            [MagicalRecord cleanUp];
        });
    });
});

SPEC_END

#pragma mark - ContactsViewController

SPEC_BEGIN(ContactsViewControllerTest)

describe(@"ContactsViewController", ^{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    __block ContactsViewController *contacts;
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
        contacts = (ContactsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"Contacts"];
    });

    afterEach(^{
        contacts = nil;
    });

    context(@"at startup", ^{
        it(@"is empty", ^{
            [[contacts valueForKey:@"_contacts"] shouldBeNil];
        });

        it(@"presents person's contacts", ^{
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];
            NSArray *people = [managedObjectContext executeFetchRequest:fetchRequest error:nil];

            Person *person = people[0];
            [contacts prepareData:person];
            [contacts view];
            [[theValue([contacts.tableView numberOfRowsInSection:0]) should] equal:theValue(3)];
        });
    });
});

SPEC_END
