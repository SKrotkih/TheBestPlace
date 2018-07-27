//
//  AIHomeScreenTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIHomeScreenTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView* iconImageView;
@property (weak, nonatomic) IBOutlet UILabel* timeLabel;

@property (weak, nonatomic) NSDictionary* activity;

@end
