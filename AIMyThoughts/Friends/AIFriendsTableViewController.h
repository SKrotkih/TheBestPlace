//
//  AIFriendsTableViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/4/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIAddFriendsSuggestionDelegate.h"

@interface AIFriendsTableViewController : UITableViewController <AIAddFriendsSuggestionDelegate>

@property (nonatomic, weak) NSArray* friends;

@end
