//
//  RLCProfilePictureView.m
//  iOSapp
//
//  Created by Evgenij on 6/10/13.
//  Copyright (c) 2013 Home. All rights reserved.
//

#import "RLCProfilePictureView.h"

@implementation RLCProfilePictureView

- (id)initWithImageView:(UIImageView *)imageView
{
    self = [super initWithFrame:imageView.frame];
    if (self) {
        if ([self respondsToSelector:@selector(setImageView:)]) {
            [self performSelector:@selector(setImageView:) withObject:imageView];
        }
    }

    return self;
}

@end
