//
//  AICompanyProfileTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AICompanyProfileViewController.h"

@interface AICompanyProfileTableViewCell : UITableViewCell

@property (nonatomic, weak) id<PressOnLikeDislikeDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel* userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* text;
@property (weak, nonatomic) IBOutlet UITextView* myToughtsTextView;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView* rateImageView;
@property (weak, nonatomic) IBOutlet UILabel* likeCounterLabel;
@property (weak, nonatomic) IBOutlet UILabel* dislikeCounterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *myFriendImageView;


@end
