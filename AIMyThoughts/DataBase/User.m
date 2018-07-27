//
//  User.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "User.h"
#import "AIUser.h"
#import "Feedback.h"

@implementation User

@dynamic userid;
@dynamic contact;
@dynamic firstname;
@dynamic gender;
@dynamic homeCity;
@dynamic lastname;
@dynamic photo_prefix;
@dynamic photo_suffix;
@dynamic email;
@dynamic name;
@dynamic fb_id;
@dynamic feedback;
@dynamic currentUser;

- (void) saveObject: (id) anObject
{
    if ([anObject isKindOfClass: [AIUser class]])
    {
        AIUser* aUser = anObject;
        self.userid = aUser.userid;
        self.contact = aUser.contact;
        self.firstname = aUser.firstname;
        self.gender = aUser.gender;
        self.homeCity = aUser.homeCity;
        self.lastname = aUser.lastname;
        self.photo_prefix = aUser.photo_prefix;
        self.photo_suffix = aUser.photo_suffix;
        self.email = aUser.email;
        self.name = aUser.name;
        self.fb_id = aUser.fb_id;
        self.currentUser = [NSNumber numberWithBool: aUser.currentUser];
    }
    else
    {
        NSAssert(NO, @"The Object has to be from AIUser class instantiated!");
    }
}

@end
