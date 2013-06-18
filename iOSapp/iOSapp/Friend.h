//
//  Friend.h
//  iOSapp
//
//  Created by Evgenij on 6/17/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString *avatarUrl;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSNumber *priority;
@property (nonatomic, retain) NSString *uid;

@end
