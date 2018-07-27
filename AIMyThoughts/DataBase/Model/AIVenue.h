//
//  AIVenue.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIVenue : NSObject

@property (nonatomic, copy) NSString* categories;
@property (nonatomic, copy) NSString* contact;
@property (nonatomic, copy) NSString* location;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* stats;
@property (nonatomic, retain) NSNumber* verified;

@end
