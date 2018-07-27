//
//  AISearchResultsTableViewCell.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import "AISearchResultsTableViewCell.h"
#import "UIImageView+DownloadImage.h"

@interface AISearchResultsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *bgRoundImageView;

@end

@implementation AISearchResultsTableViewCell

@synthesize iconNameDefault, iconNameSelected;

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

@end
