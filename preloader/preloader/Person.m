//
//  Person.m
//  iOSapp
//
//  Created by Evgenij on 6/5/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Person.h"
#import "Contact.h"


@implementation Person

@dynamic bio;
@dynamic birthdate;
@dynamic name;
@dynamic photo;
@dynamic surname;
@dynamic contacts;

#if TARGET_OS_IPHONE

- (void)setPhoto:(UIImage *)photo
{
    [self willChangeValueForKey:@"photo"];
    NSData *data = UIImagePNGRepresentation(photo);
    [self setPrimitiveValue:data forKey:@"photo"];
    [self didChangeValueForKey:@"photo"];
}

- (UIImage *)photo
{
    [self willAccessValueForKey:@"photo"];
    UIImage *image = [UIImage imageWithData:[self primitiveValueForKey:@"photo"]];
    [self didAccessValueForKey:@"photo"];
    return image;
}

#else

- (void)setPhoto:(NSImage *)photo
{
    [self willChangeValueForKey:@"photo"];
    NSBitmapImageRep *bits = [[photo representations] objectAtIndex:0];
    NSData *data = [bits representationUsingType:NSPNGFileType properties:nil];
    [self setPrimitiveValue:data forKey:@"photo"];
    [self didChangeValueForKey:@"photo"];
}

- (NSImage *)photo
{
    [self willAccessValueForKey:@"photo"];
    NSImage *image = [[NSImage alloc] initWithData:[self primitiveValueForKey:@"photo"]];
    [self didAccessValueForKey:@"photo"];
    return image;
}

#endif

@end
