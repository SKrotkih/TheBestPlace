//
//  Venue.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "Venue.h"
#import "AIVenue.h"

@implementation Venue

@dynamic categories;
@dynamic contact;
@dynamic location;
@dynamic name;
@dynamic stats;
@dynamic verified;
@dynamic feedback;

- (void) saveObject: (id) anObject
{
    if ([anObject isKindOfClass: [AIVenue class]])
    {
        AIVenue* venue = anObject;
        self.categories = venue.categories;
        self.contact = venue.contact;
        self.location = venue.location;
        self.name = venue.name;
        self.stats = venue.stats;
        self.verified = venue.verified;
    }
    else
    {
        NSAssert(NO, @"The Object has to be from AIVenue class instantiated!");
    }
}

@end
