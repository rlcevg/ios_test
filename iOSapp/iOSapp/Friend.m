//
//  Friend.m
//  iOSapp
//
//  Created by Evgenij on 6/17/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "Friend.h"


@implementation Friend

@dynamic uid;
@dynamic priority;
@dynamic avatar;
@dynamic firstName;
@dynamic lastName;

#if TARGET_OS_IPHONE

- (void)setAvatar:(UIImage *)avatar
{
    [self willChangeValueForKey:@"avatar"];
    NSData *data = UIImagePNGRepresentation(avatar);
    [self setPrimitiveValue:data forKey:@"avatar"];
    [self didChangeValueForKey:@"avatar"];
}

- (UIImage *)avatar
{
    [self willAccessValueForKey:@"avatar"];
    UIImage *image = [UIImage imageWithData:[self primitiveValueForKey:@"avatar"]];
    [self didAccessValueForKey:@"avatar"];
    return image;
}

#else

- (void)setAvatar:(NSImage *)avatar
{
    [self willChangeValueForKey:@"avatar"];
    NSBitmapImageRep *bits = [[photo representations] objectAtIndex:0];
    NSData *data = [bits representationUsingType:NSPNGFileType properties:nil];
    [self setPrimitiveValue:data forKey:@"avatar"];
    [self didChangeValueForKey:@"avatar"];
}

- (NSImage *)avatar
{
    [self willAccessValueForKey:@"avatar"];
    NSImage *image = [[NSImage alloc] initWithData:[self primitiveValueForKey:@"avatar"]];
    [self didAccessValueForKey:@"avatar"];
    return image;
}

#endif

@end
