//
//  AIFriendsFeedbacksTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIFriendsFeedbacksTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* iconImageView;
@property (nonatomic, weak) IBOutlet UILabel* placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *disLikeCountLabel;

@end
