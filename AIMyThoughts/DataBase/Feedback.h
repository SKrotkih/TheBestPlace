//
//  Feedback.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Campaign, User, Venue, AIFeedback;

@interface Feedback : NSManagedObject

@property (nonatomic, retain) NSString* feedbackid;
@property (nonatomic, retain) NSString* userid;
@property (nonatomic, retain) NSString* venueid;

@property (nonatomic, retain) NSNumber* createdAt;
@property (nonatomic, retain) NSString* photo_prefix;
@property (nonatomic, retain) NSString* photo_suffix;
@property (nonatomic, retain) NSNumber* rate;
@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* email;

@property (nonatomic, retain) NSString* campaignid;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Venue *venue;
@property (nonatomic, retain) Campaign *campaign;

- (void) saveObject: (id) anObject;

@end
