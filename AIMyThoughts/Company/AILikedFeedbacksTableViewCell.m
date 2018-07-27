//
//  AILikedFeedbacksTableViewCell.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import "AILikedFeedbacksTableViewCell.h"

@implementation AILikedFeedbacksTableViewCell

- (void) setSelected: (BOOL) selected
            animated: (BOOL) animated
{
    [super setSelected: selected
              animated: animated];
    
    UIColor* bgColor;
    
    if (selected)
    {
        bgColor = [UIColor lightGrayColor];
    }
    else
    {
        bgColor = [UIColor whiteColor];
    }
    
    self.backgroundColor = bgColor;
}

- (IBAction) addToFriendPressed: (id) sender
{
    [self.delegate pressedOnAddToFriendButtonWithRow: self.tag];
}

@end
