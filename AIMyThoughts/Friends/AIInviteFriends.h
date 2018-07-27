//
//  AIInviteFriends.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/4/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIInviteFriendsTableViewController.h"

@interface AIInviteFriends : NSObject <AIInviteFriendsDelegate>

- (id) initWithViewController: (UIViewController*) aParentViewController;
- (void) instantiateViewController;
- (void) generateDataSourse;
- (void) addRegisteredUsersForFunctor: (UserAndFriendCompareFunctor) aCompareFunctor;
- (void) sendInviteContactPeoplePickerWithViewController: (UIViewController*) aViewController;

@property (nonatomic, weak) UIViewController* parentViewController;
@property (nonatomic, strong) NSMutableArray* friends;
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) AIInviteFriendsTableViewController* inviteFriendsTableViewController;
@property (nonatomic, weak) NSArray* thoughtsBookFriends;

@end
