//
//  AIVote.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIVote.h"
#import "AIFeedback.h"
#import "UIDevice+IdentifierAddition.h"

@implementation AIVote

- (id) initWithFeedback: (AIFeedback*) aFeedback
{
    if ((self = [super init]))
    {
        _feedbackid = [aFeedback.feedbackid copy];
        _venueid = [aFeedback.venueid copy];
        _device_id = [[[UIDevice currentDevice] uniqueDeviceIdentifier] copy];

        CFTimeInterval theTimeInterval = [[NSDate date] timeIntervalSince1970];
        _createdAt = [NSNumber numberWithDouble: theTimeInterval];
    }
    
    return self;
}

- (id) initWithDict: (NSDictionary*) aDict
{
    if ((self = [self init]))
    {
        self.userid = aDict[@"userid"];
        self.device_id = aDict[@"device_id"];
        self.venueid = aDict[@"venueid"];
        self.feedbackid = aDict[@"feedbackid"];
        self.like = aDict[@"like"];
        self.createdAt = [NSNumber numberWithDouble: [aDict[@"createdAt"] doubleValue]];
    }
    
    return self;
}

- (NSString*) stringOfDateCreatedAt
{
    CFTimeInterval theTimeInterval = [_createdAt doubleValue];
    NSDate* datePublished = [NSDate dateWithTimeIntervalSince1970: theTimeInterval];
    NSString* dateString = [NSDateFormatter localizedStringFromDate: datePublished
                                                          dateStyle: NSDateFormatterMediumStyle
                                                          timeStyle: NSDateFormatterNoStyle];
    
    return dateString;
}


@end
