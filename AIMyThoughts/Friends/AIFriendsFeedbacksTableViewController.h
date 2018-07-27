//
//  AIFriendsFeedbacksTableViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/6/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIUser.h"

@interface AIFriendsFeedbacksTableViewController : UITableViewController

@property (nonatomic, weak) AIUser* user;
@property (nonatomic, assign) BOOL isItMyThoughts;
@property (nonatomic, assign) BOOL needReloadFeedData;

@end
