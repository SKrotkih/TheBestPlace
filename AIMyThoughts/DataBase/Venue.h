//
//  Venue.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Feedback.h"

@interface Venue : NSManagedObject

@property (nonatomic, retain) NSString * categories;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * stats;
@property (nonatomic, retain) NSNumber * verified;
@property (nonatomic, retain) NSSet *feedback;
@end

@interface Venue (CoreDataGeneratedAccessors)

- (void) saveObject: (id) anObject;
- (void)addFeedbackObject:(Feedback*)value;
- (void)removeFeedbackObject:(Feedback*)value;
- (void)addFeedback:(NSSet *)values;
- (void)removeFeedback:(NSSet *)values;

@end
