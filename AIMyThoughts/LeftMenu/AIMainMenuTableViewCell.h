//
//  AIMainMenuTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIMainMenuTableViewCell : UITableViewCell
{
    NSString* iconNameDefault;
    NSString* iconNameSelected;
}

@property (nonatomic, assign) BOOL disable;

@property (nonatomic, weak) IBOutlet UIImageView* iconImageView;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;

@property (nonatomic, copy) NSString* iconNameDefault;
@property (nonatomic, copy) NSString* iconNameSelected;
@property (nonatomic, copy) NSString* iconNameDisabled;

@end
