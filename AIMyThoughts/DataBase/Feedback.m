//
//  Feedback.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "Feedback.h"
#import "Campaign.h"
#import "User.h"
#import "Venue.h"
#import "AIFeedback.h"

@implementation Feedback

@dynamic feedbackid;
@dynamic userid;
@dynamic venueid;

@dynamic createdAt;
@dynamic photo_prefix;
@dynamic photo_suffix;
@dynamic rate;
@dynamic text;
@dynamic name;
@dynamic email;

@dynamic campaignid;
@dynamic user;
@dynamic venue;
@dynamic campaign;

- (void) saveObject: (id) anObject
{
    if ([anObject isKindOfClass: [AIFeedback class]])
    {
        AIFeedback* aFeedback = anObject;
        self.feedbackid  = aFeedback.feedbackid;
        self.userid  = aFeedback.userid;
        self.venueid  = aFeedback.venueid;
        
        self.text  = aFeedback.text;
        self.createdAt = aFeedback.createdAt;
        self.name = aFeedback.name;
        self.email = aFeedback.email;
        self.photo_prefix  = aFeedback.photo_prefix;
        self.photo_suffix  = aFeedback.photo_suffix;
        self.rate = aFeedback.rate;
        
        self.campaignid = aFeedback.campaignid;
    }
    else
    {
        NSAssert(NO, @"The Object has to be from AIFeedback class instantiated!");
    }
}

@end
