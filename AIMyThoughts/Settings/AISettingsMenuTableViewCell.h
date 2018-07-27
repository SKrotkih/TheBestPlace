//
//  AISettingsMenuTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AISettingsMenuTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL disable;
@property (nonatomic, copy) NSString* iconNameDefault;
@property (nonatomic, copy) NSString* iconNameDisable;

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;


@end
