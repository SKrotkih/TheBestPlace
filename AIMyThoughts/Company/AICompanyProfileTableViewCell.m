//
//  AICompanyProfileTableViewCell.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import "AICompanyProfileTableViewCell.h"

@implementation AICompanyProfileTableViewCell

- (void) setSelected: (BOOL) selected
            animated: (BOOL) animated
{
    [super setSelected: selected
              animated: animated];
    
    UIColor* bgColor;
    
    if (selected)
    {
        bgColor = [UIColor lightGrayColor];
    }
    else
    {
        bgColor = [UIColor whiteColor];
    }
    
    self.backgroundColor = bgColor;
}


#pragma mark Like - Dislike

- (IBAction) likeButtonPressed: (id) sender
{
    NSInteger likeCounter = [self.likeCounterLabel.text integerValue];
    
    if (likeCounter > 0)
    {
        [self.delegate likeButtonPressed: self];
    }
}

- (IBAction) dislikeButtonPressed: (id) sender
{
    NSInteger disLikeCounter = [self.dislikeCounterLabel.text integerValue];

    if (disLikeCounter > 0)
    {
        [self.delegate disLikeButtonPressed: self];
    }
}

#pragma mark -

@end
