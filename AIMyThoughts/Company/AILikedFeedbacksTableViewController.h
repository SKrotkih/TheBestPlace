//
//  AILikedFeedbacksTableViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/6/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIFeedback.h"

@protocol PressOnLikedFeedbacksDelegate <NSObject>
- (void) pressedOnAddToFriendButtonWithRow: (NSInteger) aRow;
@end


@interface AILikedFeedbacksTableViewController : UITableViewController <PressOnLikedFeedbacksDelegate>

@property (nonatomic, assign)  BOOL isLiked;
@property (nonatomic, weak) AIFeedback* feedback;
@property (nonatomic, weak) NSArray* dataSource;

@end
