//
//  main.m
//  preloader
//
//  Created by Evgenij on 6/4/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Person.h"
#import "Contact.h"


static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"iOSapp";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingLastPathComponent];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"iOSapp.sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        NSError *err = nil;
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"Person" ofType:@"json"];
        NSArray *people = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
        NSLog(@"Imported People: %@", people);
        [people enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Person *person = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Person"
                              inManagedObjectContext:context];
            person.name = [obj objectForKey:@"name"];
            person.surname = obj[@"surname"];
            person.bio = obj[@"bio"];

            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd/mm/yyyy"];
            NSDate *date = [dateFormat dateFromString:obj[@"birthdate"]];
            person.birthdate = date;

            NSString *photo = obj[@"photo"];
            person.photo = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[photo stringByDeletingPathExtension] ofType:@"jpg"]];
            NSArray *obj_contacts = obj[@"contacts"];
            for (NSDictionary *obj_contact in obj_contacts) {
                Contact *contact = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"Contact"
                                    inManagedObjectContext:context];
                contact.type = obj_contact[@"type"];
                contact.contact = obj_contact[@"contact"];
                [person addContactsObject:contact];
            }
        }];

        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
    }
    return 0;
}

