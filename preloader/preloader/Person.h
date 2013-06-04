//
//  Person.h
//  iOSapp
//
//  Created by Evgenij on 6/4/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <AppKit/AppKit.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * surname;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSImage * photo;

@end
