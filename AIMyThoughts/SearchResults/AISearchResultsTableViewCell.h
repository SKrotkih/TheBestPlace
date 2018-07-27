//
//  AISearchResultsTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AISearchResultsTableViewCell : UITableViewCell
{
    NSString* iconNameDefault;
    NSString* iconNameSelected;
}

@property (nonatomic, weak) IBOutlet UIImageView* iconImageView;
@property (nonatomic, copy) NSString* imageUrl;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* addressLabel;
@property (nonatomic, weak) IBOutlet UILabel* distanceLabel;

@property (nonatomic, copy) NSString* iconNameDefault;
@property (nonatomic, copy) NSString* iconNameSelected;

@end
