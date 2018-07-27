//
//  Campaign.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AICampaign : NSObject

@property (nonatomic, copy) NSString * contact;
@property (nonatomic, copy) NSNumber * endsAt;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * photo_prefix;
@property (nonatomic, copy) NSString * photo_suffix;
@property (nonatomic, copy) NSNumber * startsAt;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, copy) NSNumber * venueGroups_count;
@property (nonatomic, copy) NSString * venueGroups_items;
@property (nonatomic, retain) NSNumber * venues_count;
@property (nonatomic, copy) NSString * venues_items;

@end
