//
//  DataTabBarController.h
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Person;

@interface DataTabBarController : UITabBarController <UITabBarControllerDelegate>

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)reloadData;
- (void)saveContext;

@end
