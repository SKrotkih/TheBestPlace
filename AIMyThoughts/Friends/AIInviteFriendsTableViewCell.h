//
//  AIInviteFriendsTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGMedallionView.h"

@interface AIInviteFriendsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet AGMedallionView* iconView;
@property (nonatomic, weak) IBOutlet UIImageView* accessImageView;
@property (nonatomic, copy) NSString* imageUrl;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;

@end
