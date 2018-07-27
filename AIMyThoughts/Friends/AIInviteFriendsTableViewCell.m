//
//  AIInviteFriendsTableViewCell.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import "AIInviteFriendsTableViewCell.h"
#import "AGMedallionView+DownloadImage.h"

@interface AIInviteFriendsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *bgRoundImageView;

@end

@implementation AIInviteFriendsTableViewCell

- (void) setImageUrl: (NSString*) imageUrl
{
    [self.iconView asyncDownloadImageURL: imageUrl
                   placeholderImageNamed: @"profile-icon"];
}

@end
