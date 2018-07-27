//
//  AILikedFeedbacksTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AILikedFeedbacksTableViewController.h"
#import "AGMedallionView.h"

@interface AILikedFeedbacksTableViewCell : UITableViewCell

@property (nonatomic, weak) id<PressOnLikedFeedbacksDelegate> delegate;

@property (weak, nonatomic) IBOutlet AGMedallionView *photoFriendsImageView;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;


@end
