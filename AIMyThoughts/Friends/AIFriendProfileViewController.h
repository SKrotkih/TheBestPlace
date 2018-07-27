//
//  AIFriendProfileViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIUser.h"

@interface AIFriendProfileViewController: UIViewController

@property(nonatomic, weak) AIUser* user;
@property(nonatomic, assign) BOOL isHeMyFriend;

@end
