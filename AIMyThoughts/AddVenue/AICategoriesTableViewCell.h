//
//  AICategoriesTableViewCell.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/8/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AICategoriesTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString* imageUrl;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkedImageView;

@property (nonatomic, assign) BOOL checked;

@end
