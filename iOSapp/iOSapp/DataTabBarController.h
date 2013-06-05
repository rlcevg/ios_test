//
//  DataTabBarController.h
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface DataTabBarController : UITabBarController <UITabBarControllerDelegate>

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
