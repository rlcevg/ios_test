//
//  EditUserDataTest.m
//  iOSapp
//
//  Created by Evgenij on 6/15/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Kiwi.h"
#import "CoreData+MagicalRecord.h"
#import "Person.h"
#import "Contact.h"
#import "DataTabBarController.h"
#import "ProfileViewController.h"
#import "BioViewController.h"

static NSString *TEST_USER_NAME = @"Testusername";
static NSString *TEST_USER_SURNAME = @"Testusersurname";
static NSString *LONG_LITERAL = @"AAAabcdefghijabcdefghijabcdefghijabcdefghij";
static NSString *TEST_ABOUT = @"Once upon a time...";


SPEC_BEGIN(ProfileEditTests)

describe(@"ProfileViewController", ^{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    context(@"when edited", ^{
        __block ProfileViewController *viewController = nil;
        __block Person *person = nil;

        beforeEach(^{
            [MagicalRecord setupCoreDataStackWithInMemoryStore];
            person = [Person MR_createEntity];
            DataTabBarController *parentController = (DataTabBarController *)[storyBoard instantiateViewControllerWithIdentifier:@"DataTabBar"];
            parentController.managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            viewController = parentController.viewControllers[0];
            [viewController prepareData:person];
            [viewController loadView];
        });

        afterEach(^{
            [MagicalRecord cleanUp];
        });

        context(@"should have name text field", ^{
            beforeEach(^{
                person.name = TEST_USER_NAME;
                [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
                [viewController viewDidLoad];
            });

            it(@"should have name edit capability", ^{
                [[theValue([viewController textFieldShouldBeginEditing:viewController.nameText]) should] equal:@YES];
                [[viewController should] respondToSelector:@selector(textFieldShouldReturn:)];
            });

            it(@"should save new name if needed", ^{
                [[person.name should] equal:TEST_USER_NAME];
                [[viewController.nameText.text should] equal:TEST_USER_NAME];
                NSString *test_str = [[NSString alloc] initWithFormat:@"%@%@", TEST_USER_NAME, TEST_USER_NAME];
                [viewController textFieldDidBeginEditing:viewController.nameText];
                viewController.nameText.text = test_str;
                [viewController textFieldShouldReturn:viewController.nameText];
                [[person.name should] equal:test_str];
                [[viewController.nameText.text should] equal:test_str];
            });

            it(@"should cancel new name if needed", ^{
                [[person.name should] equal:TEST_USER_NAME];
                [[viewController.nameText.text should] equal:TEST_USER_NAME];
                NSString *test_str = [[NSString alloc] initWithFormat:@"%@%@", TEST_USER_NAME, TEST_USER_NAME];
                [viewController textFieldDidBeginEditing:viewController.nameText];
                viewController.nameText.text = test_str;
                [viewController performSelector:@selector(responderCancel)];
                [[person.name should] equal:TEST_USER_NAME];
                [[viewController.nameText.text should] equal:TEST_USER_NAME];
            });

            it(@"should have new name validation", ^{
                [[theValue([viewController textField:viewController.nameText
                       shouldChangeCharactersInRange:NSMakeRange(0, 5)
                                   replacementString:@"12345"]) should] equal:@NO];
                [[theValue([viewController textField:viewController.nameText
                       shouldChangeCharactersInRange:NSMakeRange(40, 5)
                                   replacementString:LONG_LITERAL]) should] equal:@NO];
                [[theValue([viewController textField:viewController.nameText
                       shouldChangeCharactersInRange:NSMakeRange(0, 0)
                                   replacementString:@"abcd"]) should] equal:@YES];

            });
        });

        context(@"should have surname text field", ^{
            beforeEach(^{
                person.surname = TEST_USER_SURNAME;
                [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
                [viewController viewDidLoad];
            });

            it(@"should have surname edit capability", ^{
                [[theValue([viewController textFieldShouldBeginEditing:viewController.surnameText]) should] equal:@YES];
                [[viewController should] respondToSelector:@selector(textFieldShouldReturn:)];
            });

            it(@"should save new surname if needed", ^{
                [[person.surname should] equal:TEST_USER_SURNAME];
                [[viewController.surnameText.text should] equal:TEST_USER_SURNAME];
                NSString *test_str = [[NSString alloc] initWithFormat:@"%@%@", TEST_USER_SURNAME, TEST_USER_SURNAME];
                [viewController textFieldDidBeginEditing:viewController.surnameText];
                viewController.surnameText.text = test_str;
                [viewController textFieldShouldReturn:viewController.surnameText];
                [[person.surname should] equal:test_str];
                [[viewController.surnameText.text should] equal:test_str];
            });

            it(@"should cancel new surname if needed", ^{
                [[person.surname should] equal:TEST_USER_SURNAME];
                [[viewController.surnameText.text should] equal:TEST_USER_SURNAME];
                NSString *test_str = [[NSString alloc] initWithFormat:@"%@%@", TEST_USER_SURNAME, TEST_USER_SURNAME];
                [viewController textFieldDidBeginEditing:viewController.surnameText];
                viewController.surnameText.text = test_str;
                [viewController performSelector:@selector(responderCancel)];
                [[person.surname should] equal:TEST_USER_SURNAME];
                [[viewController.surnameText.text should] equal:TEST_USER_SURNAME];
            });

            it(@"should have new surname validation", ^{
                [[theValue([viewController textField:viewController.surnameText
                       shouldChangeCharactersInRange:NSMakeRange(0, 5)
                                   replacementString:@"12345"]) should] equal:@NO];
                [[theValue([viewController textField:viewController.surnameText
                       shouldChangeCharactersInRange:NSMakeRange(40, 5)
                                   replacementString:LONG_LITERAL]) should] equal:@NO];
                [[theValue([viewController textField:viewController.surnameText
                       shouldChangeCharactersInRange:NSMakeRange(0, 0)
                                   replacementString:@"abcd"]) should] equal:@YES];
                
            });
        });

        __block NSDate *TEST_DATE;
        context(@"should have birthday date field", ^{
            NSDateFormatter* (^dateFormatter) (void) = ^NSDateFormatter* (void) {
                static NSDateFormatter *dateFormatter = nil;
                if (!dateFormatter) {
                    dateFormatter = [NSDateFormatter new];
                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                }
                return dateFormatter;
            };
            NSDate* (^dateFromString) (NSString*) = ^NSDate* (NSString *dateString) {
                return [dateFormatter() dateFromString:dateString];
            };
            NSString* (^stringFromDate) (NSDate*) = ^NSString* (NSDate *date) {
                return [dateFormatter() stringFromDate:date];
            };

            beforeEach(^{
                TEST_DATE = dateFromString(@"Dec 24, 2000");
                person.birthdate = TEST_DATE;
                [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
                [viewController viewDidLoad];
            });

            it(@"should change displayed value on date change", ^{
                NSDate *date1 = dateFromString(@"Oct 30, 2002");
                viewController.birthdateText.date = date1;
                [[viewController.birthdateText.text should] equal:stringFromDate(TEST_DATE)];
                [viewController.birthdateText.dateView sendActionsForControlEvents:UIControlEventValueChanged];
                [[viewController.birthdateText.text should] equal:stringFromDate(date1)];
            });

            it(@"should save new date if needed", ^{
                NSDate *date1 = dateFromString(@"Oct 30, 2002");
                [[person.birthdate should] equal:TEST_DATE];
                [viewController textFieldDidBeginEditing:viewController.birthdateText];
                viewController.birthdateText.date = date1;
                [viewController.birthdateText.dateView sendActionsForControlEvents:UIControlEventValueChanged];
                [viewController.birthdateText performSelector:@selector(save)];
                [[person.birthdate should] equal:date1];
            });

            it(@"should cancel new date if needed", ^{
                NSDate *date1 = dateFromString(@"Oct 30, 2002");
                [[person.birthdate should] equal:TEST_DATE];
                [viewController textFieldDidBeginEditing:viewController.birthdateText];
                viewController.birthdateText.date = date1;
                [viewController.birthdateText.dateView sendActionsForControlEvents:UIControlEventValueChanged];
                [viewController.birthdateText performSelector:@selector(cancel)];
                [[person.birthdate should] equal:TEST_DATE];
            });
        });
    });
});

SPEC_END


SPEC_BEGIN(AboutEditTests)

describe(@"BioViewController", ^{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    context(@"when edited", ^{
        __block BioViewController *viewController = nil;
        __block Person *person = nil;

        beforeEach(^{
            [MagicalRecord setupCoreDataStackWithInMemoryStore];
            person = [Person MR_createEntity];
            DataTabBarController *parentController = (DataTabBarController *)[storyBoard instantiateViewControllerWithIdentifier:@"DataTabBar"];
            parentController.managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
            viewController = parentController.viewControllers[1];
            [viewController prepareData:person];
            [viewController loadView];
        });

        afterEach(^{
            [MagicalRecord cleanUp];
        });

        context(@"should have about text view", ^{
            beforeEach(^{
                person.bio = TEST_ABOUT;
                [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
                [viewController viewDidLoad];
            });

            it(@"should edit about", ^{
                [[theValue([viewController textViewShouldBeginEditing:viewController.bioText]) should] equal:@YES];
            });

            it(@"should save new about if needed", ^{
                [[person.bio should] equal:TEST_ABOUT];
                [[viewController.bioText.text should] equal:TEST_ABOUT];
                NSString *test_str = [[NSString alloc] initWithFormat:@"%@%@", TEST_ABOUT, TEST_ABOUT];
                viewController.bioText.text = test_str;
                [viewController performSelector:@selector(textViewSave:) withObject:viewController.bioText];
                [[person.bio should] equal:test_str];
                [[viewController.bioText.text should] equal:test_str];
            });

            it(@"should cancel new about if needed", ^{
                [[person.bio should] equal:TEST_ABOUT];
                [[viewController.bioText.text should] equal:TEST_ABOUT];
                NSString *test_str = [[NSString alloc] initWithFormat:@"%@%@", TEST_ABOUT, TEST_ABOUT];
                viewController.bioText.text = test_str;
                [viewController performSelector:@selector(textViewCancel:) withObject:viewController.bioText];
                [[person.bio should] equal:TEST_ABOUT];
                [[viewController.bioText.text should] equal:TEST_ABOUT];
            });
        });
    });
});

SPEC_END
