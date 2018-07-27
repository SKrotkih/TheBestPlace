//
//  AIFriendsSuggTableViewCell.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import "AIFriendsSuggTableViewCell.h"
#import "AGMedallionView+DownloadImage.h"

@interface AIFriendsSuggTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *bgRoundImageView;

@end

@implementation AIFriendsSuggTableViewCell
{
    NSInteger _section;
    NSInteger _row;
}

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
    [self.iconView asyncDownloadImageURL: imageUrl
                   placeholderImageNamed: @"profile-icon"];
}

#pragma mark Property

- (void) setIndexPath: (NSIndexPath*) indexPath
{
    _section = indexPath.section;
    _row = indexPath.row;
}

- (NSIndexPath*) indexPath
{
    return [NSIndexPath indexPathForRow: _row
                              inSection: _section];
}

#pragma mark -

- (IBAction) addFriendButtonPressed: (id) sender
{
    [self.delegate addButtonPressedOnCellWithIndexPath: self.indexPath];
}

- (IBAction) excludeRowButtonPressed: (id) sender
{
    [self.delegate excludeButtonPressedOnCellWithIndexPath: self.indexPath];
}

@end
