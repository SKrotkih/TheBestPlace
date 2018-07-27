//
//  Campaign.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Feedback.h"

@interface Campaign : NSManagedObject

@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSNumber * endsAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photo_prefix;
@property (nonatomic, retain) NSString * photo_suffix;
@property (nonatomic, retain) NSNumber * startsAt;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * venueGroups_count;
@property (nonatomic, retain) NSString * venueGroups_items;
@property (nonatomic, retain) NSNumber * venues_count;
@property (nonatomic, retain) NSString * venues_items;
@property (nonatomic, retain) NSSet *feedback;
@end

@interface Campaign (CoreDataGeneratedAccessors)

- (void) saveObject: (id) anObject;
- (void)addFeedbackObject:(Feedback*)value;
- (void)removeFeedbackObject:(Feedback*)value;
- (void)addFeedback:(NSSet *)values;
- (void)removeFeedback:(NSSet *)values;

@end
