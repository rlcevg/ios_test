//
//  DataTab.h
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@protocol DataTab <NSObject>

- (void)prepareData:(Person *)person;

@end
