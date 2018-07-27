//
//  AICategoriesTableViewCell.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/8/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AICategoriesTableViewCell.h"
#import "UIImageView+DownloadImage.h"

@interface AICategoriesTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *bgRoundImageView;
@end

@implementation AICategoriesTableViewCell

- (void) setHighlighted: (BOOL) highlighted
               animated: (BOOL)animated
{
    [super setHighlighted: highlighted
                 animated: animated];
    
    if (highlighted)
    {
        self.bgRoundImageView.image = nil;
    }
    else
    {
        self.bgRoundImageView.image = [UIImage imageNamed: @"bg_image_round.png"];
    }
}

- (void) setImageUrl: (NSString*) imageUrl
{
    [_iconImageView asyncDownloadImageURL: imageUrl
                    placeholderImageNamed: @"empty_square"];
}

- (void) setChecked: (BOOL)checked
{
    _checked = checked;
    self.checkedImageView.hidden = !_checked;
}

@end

