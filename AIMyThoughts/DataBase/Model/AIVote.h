//
//  AIVote.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIFeedback;

@interface AIVote : NSObject

- (id) initWithFeedback: (AIFeedback*) aFeedback;

@property (nonatomic, copy) NSString* userid;
@property (nonatomic, copy) NSString* feedbackid;
@property (nonatomic, copy) NSString* device_id;
@property (nonatomic, copy) NSString* venueid;
@property (nonatomic, copy) NSString* like;
@property (nonatomic, copy) NSNumber* createdAt;

- (id) initWithDict: (NSDictionary*) aDict;
- (NSString*) stringOfDateCreatedAt;

@end
