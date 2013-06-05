//
//  Contact.h
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString *contact;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) Person *person;

@end
