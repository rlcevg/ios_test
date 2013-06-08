//
//  Person.h
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <AppKit/AppKit.h>

@class Contact;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSDate *birthdate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSImage *photo;
@property (nonatomic, retain) NSString *surname;
@property (nonatomic, retain) NSSet *contacts;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
