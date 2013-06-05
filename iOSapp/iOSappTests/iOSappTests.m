//
//  iOSappTests.m
//  iOSappTests
//
//  Created by Evgenij on 6/4/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Kiwi.h"
#import "CoreData+MagicalRecord.h"
#import "Person.h"

SPEC_BEGIN(StorageSpec)

describe(@"PersonEntity", ^{
    beforeEach(^{
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
        NSArray *people = [Person MR_findAll];
        [[theValue([people count]) should] equal:theValue(1)];

        Person *person = people[0];
        [[person.name should] equal:@"Евгений"];
        [[person.surname should] equal:@"surЕвгений"];
        [[person.bio should] startWithString:@"По снегам ли зимой иль по хляби осенней"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/mm/yyyy"];
        NSDate *date = [dateFormat dateFromString:@"01/01/1970"];
        [[person.birthdate should] equal:date];
        [person.photo shouldNotBeNil];
        [[person.photo should] beMemberOfClass:[UIImage class]];
        [[theValue([person.contacts count]) should] equal:theValue(3)];
    });

});

SPEC_END