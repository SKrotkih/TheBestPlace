//
//  AISettingsMenuTableViewCell.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import "AISettingsMenuTableViewCell.h"
#import "Utils.h"

@implementation AISettingsMenuTableViewCell

- (void) setHighlighted: (BOOL) highlighted
               animated: (BOOL)animated
{
    [super setHighlighted: highlighted
                 animated: animated];
    
    [self setSelected: highlighted
             animated: animated];
}

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

    if (self.disable)
    {
        UIColor* textColor = [Utils colorWithRGBHex: 0xF0F0F0];
        self.nameLabel.textColor = textColor;
        self.iconImageView.image = [UIImage imageNamed: self.iconNameDisable];
    }
    else
    {
        UIColor* textColor = [Utils colorWithRGBHex: 0x494949];
        self.nameLabel.textColor = textColor;
        self.iconImageView.image = [UIImage imageNamed: self.iconNameDefault];
    }
}

@end
