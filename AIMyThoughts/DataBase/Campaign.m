//
//  Campaign.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "Campaign.h"
#import "AICampaign.h"

@implementation Campaign

@dynamic contact;
@dynamic endsAt;
@dynamic name;
@dynamic photo_prefix;
@dynamic photo_suffix;
@dynamic startsAt;
@dynamic text;
@dynamic venueGroups_count;
@dynamic venueGroups_items;
@dynamic venues_count;
@dynamic venues_items;
@dynamic feedback;

- (void) saveObject: (id) anObject
{
    if ([anObject isKindOfClass: [AICampaign class]])
    {
        AICampaign* campaign = anObject;
        self.contact = campaign.contact;
        self.endsAt = campaign.endsAt;
        self.name = campaign.name;
        self.photo_prefix = campaign.photo_prefix;
        self.photo_suffix = campaign.photo_suffix;
        self.startsAt = campaign.startsAt;
        self.text = campaign.text;
        self.venueGroups_count = campaign.venueGroups_count;
        self.venueGroups_items = campaign.venueGroups_items;
        self.venues_count = campaign.venues_count;
        self.venues_items = campaign.venues_items;
    }
    else
    {
        NSAssert(NO, @"The Object has to be from AICampaign class instantiated!");
    }
}

@end
