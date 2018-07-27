//
//  User.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AIUser, Feedback;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString* userid;
@property (nonatomic, retain) NSString* contact;
@property (nonatomic, retain) NSString* firstname;
@property (nonatomic, retain) NSString* gender;
@property (nonatomic, retain) NSString* homeCity;
@property (nonatomic, retain) NSString* lastname;
@property (nonatomic, retain) NSString* photo_prefix;
@property (nonatomic, retain) NSString* photo_suffix;
@property (nonatomic, retain) NSString* email;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* fb_id;
@property (nonatomic, retain) NSNumber* currentUser;
@property (nonatomic, retain) NSSet* feedback;

- (void) saveObject: (AIUser*) aUser;

@end

@interface User (CoreDataGeneratedAccessors)

- (void) addFeedbackObject:(Feedback*)value;
- (void) removeFeedbackObject:(Feedback*)value;
- (void) addFeedback:(NSSet *)values;
- (void) removeFeedback:(NSSet *)values;

@end
