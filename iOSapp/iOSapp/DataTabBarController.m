//
//  DataTabBarController.m
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "DataTabBarController.h"
#import "DataTab.h"
#import "Person.h"
#import "Contact.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ProfileViewController.h"
#import "RLCProfilePictureView.h"

#pragma mark - DataTabBarController interface

@interface DataTabBarController ()

@property (strong, nonatomic) RLCProfilePictureView *fbProfilePictureView;
@property (assign, nonatomic, getter=isLoading) BOOL loading;

@end

#pragma mark - DataTabBarController implementation

@implementation DataTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.delegate = self;
    if (!self.loading) {
        [self.viewControllers[0] prepareData:self.person];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Person *)person
{
    if (_person != nil) {
        return _person;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
    }

    if ([fetchedObjects count] > 0) {
        _person = fetchedObjects[0];
    }
    return _person;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController conformsToProtocol:@protocol(DataTab)]) {
        [(id<DataTab>)viewController prepareData:self.person];
    }
    return YES;
}

- (void)clearPersonData
{
    Person *person = self.person;
    if (person) {
        [self.managedObjectContext deleteObject:person];
        self.person = nil;
    }
    self.loading = YES;
}

- (void)reloadData
{
    if (FBSession.activeSession.isOpen) {
        [self clearPersonData];
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 NSManagedObjectContext *managedObjectContext = self.managedObjectContext;

                 Person *person = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"Person"
                                   inManagedObjectContext:managedObjectContext];

                 person.name = user.first_name;
                 person.surname = user.last_name;
                 NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                 [dateFormat setDateFormat:@"dd/mm/yyyy"];
                 NSDate *date = [dateFormat dateFromString:user.birthday];
                 person.birthdate = date;
                 person.bio = user[@"bio"];
                 [person removeContacts:person.contacts];
                 Contact *contact = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"Contact"
                                     inManagedObjectContext:managedObjectContext];
                 contact.type = @"email";
                 contact.contact = user[@"email"];
                 [person addContactsObject:contact];
                 if (![managedObjectContext save:&error]) {
                     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                     abort();
                 }
                 self.person = person;

                 ProfileViewController *profileController = self.viewControllers[0];
                 [profileController prepareData:person];
                 [profileController populateUserDetails];
                 self.fbProfilePictureView = [[RLCProfilePictureView alloc] initWithImageView:profileController.photoView];
                 [self.fbProfilePictureView addObserver:self forKeyPath:@"imageView.image" options:NSKeyValueObservingOptionNew context:NULL];
                 self.fbProfilePictureView.profileID = user.id;
             }
         }];
    }
}

- (void)didLoadPhoto:(UIImage *)photo
{
    // TODO: deal with missing photo situation, when downloading is not completed but application closed
    self.person.photo = photo;
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    ProfileViewController *profileController = self.viewControllers[0];
    [profileController populateUserPhoto];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"imageView.image"]) {
        [self.fbProfilePictureView removeObserver:self forKeyPath:@"imageView.image"];
        [self didLoadPhoto:[change objectForKey:NSKeyValueChangeNewKey]];
    }
    /*
     Be sure to call the superclass's implementation *if it implements it*.
     NSObject does not implement the method.
     */
//    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
