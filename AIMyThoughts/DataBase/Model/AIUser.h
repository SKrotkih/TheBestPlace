//
//  AIUser.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface AIUser : NSObject
{
    NSString* _photo_suffix;
    NSString* _photo_prefix;
}

@property (nonatomic, copy) NSString* userid;
@property (nonatomic, copy) NSString* contact;
@property (nonatomic, copy) NSString* firstname;
@property (nonatomic, copy) NSString* gender;
@property (nonatomic, copy) NSString* homeCity;
@property (nonatomic, copy) NSString* lastname;
@property (nonatomic, copy) NSString* photo_prefix;
@property (nonatomic, copy) NSString* photo_suffix;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* fb_id;
@property (nonatomic, assign) BOOL currentUser;

+ (AIUser*) currentUser;

- (id) initWithObject: (User*) aUser;
- (id) initWithFacebookInfo: (NSDictionary*) user;
- (id) initWithDict: (NSDictionary*) aDict;

- (void) updateWithFacebookInfo: (NSDictionary*) graphUser;
- (void) updateWithInfo: (NSDictionary*) userInfo;

- (NSString*) userName;

- (void) addFriend: (AIUser*) aFriend;

- (void) removeFriendWithID: (NSString*) aFriendId
               forUserId: (NSString*) aUserId
         viewController: (UIViewController*) aViewController
               resultBlock: (void (^)(NSError *error)) callback;

@end
