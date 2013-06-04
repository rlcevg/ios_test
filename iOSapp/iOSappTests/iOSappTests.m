//
//  iOSappTests.m
//  iOSappTests
//
//  Created by Evgenij on 6/4/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Kiwi.h"
#import "CoreData+MagicalRecord.h"

SPEC_BEGIN(StorageSpec)

describe(@"PersonEntity", ^{
    beforeEach(^{
//        [MagicalRecord setupCoreDataStackWithInMemoryStore];
        [MagicalRecord setupCoreDataStack];
    });

    afterEach(^{
        [MagicalRecord cleanUp];
    });

    it(@"should create a new object", ^{
        Person *person = [Person MR_createEntity];

        [person shouldNotBeNil];
        [person.name shouldBeNil];
        [person.surname shouldBeNil];
        [person.bio shouldBeNil];
        [person.photo shouldBeNil];
    });

    it(@"should have preloaded data", ^{
//        NSManagedObjectContext *testContext = [NSManagedObjectContext MR_context];
        NSArray *people = [Person MR_findAll];
        [[theValue(people count) should] equal:theValue(1)];

        [[person.name should] equal:@"Name placeholder"];
        [[person.surname should] equal:@"Surname placeholder"];
        [[person.bio should] equal:@"Bio placeholder"];
        [person.photo shouldNotBeNil];
        [[person.photo should] beMemberOfClass:UIImage];
    });

});

SPEC_END