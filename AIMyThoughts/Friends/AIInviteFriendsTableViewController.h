//
//  AIInviteFriendsTableViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/4/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AIUser.h"

typedef BOOL(^UserAndFriendCompareFunctor)(AIUser* user, NSDictionary* friend);

@protocol AIInviteFriendsDelegate <NSObject>
- (void) viewDidLoad;
- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath;
- (void) handleRefresh: (id) paramSender;
@end

@interface AIInviteFriendsTableViewController : UITableViewController

@property (nonatomic, weak) NSMutableArray* friends;
@property (nonatomic, weak) NSMutableArray* users;
@property (nonatomic, weak) id<AIInviteFriendsDelegate> delegate;

@property (nonatomic, copy) NSString* titleText;
@property (nonatomic, copy) NSString* titleSection0;
@property (nonatomic, copy) NSString* titleSection1;

- (void) reloadData;


@end
