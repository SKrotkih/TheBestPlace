//
//  AIMainMenuTableViewCell.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 09/06/13.
//  Copyright (c) 2013 Ainstainer Group. All rights reserved.
//

#import "AIMainMenuTableViewCell.h"
#import "Utils.h"

@implementation AIMainMenuTableViewCell

@synthesize iconNameDefault, iconNameSelected;

- (void) setHighlighted: (BOOL) highlighted
               animated: (BOOL)animated
{
    [super setHighlighted: highlighted
                 animated: animated];
    
    UIColor* bgColor;
    UIColor* textColor;
    
    if (highlighted)
    {
        if (self.disable)
        {
            if (self.iconImageView)
            {
                self.iconImageView.image = [UIImage imageNamed:  self.iconNameDisabled];
            }
            
            UIColor* bgColor = [Utils colorWithRGBHex: 0x414141];
            UIColor* textColor = [Utils colorWithRGBHex: 0x000000];
            self.backgroundColor = bgColor;
            self.nameLabel.textColor = textColor;
        }
        else
        {
            if (self.iconImageView)
            {
                self.iconImageView.image = [UIImage imageNamed:  [NSString stringWithFormat: @"%@", self.iconNameSelected]];
            }
            bgColor = [Utils colorWithRGBHex: 0x393939];
            textColor = [Utils colorWithRGBHex: 0xFEFEFE];
            self.backgroundColor = bgColor;
            self.nameLabel.textColor = textColor;
        }
    }
    else
    {
        [self setDefaultImage];
    }
}

- (void) setSelected: (BOOL) selected
            animated: (BOOL) animated
{
    [super setSelected: selected
              animated: animated];
    
    [self setDefaultImage];
}

- (void) setDefaultImage
{
    if (self.disable)
    {
        if (self.iconImageView)
        {
            self.iconImageView.image = [UIImage imageNamed:  self.iconNameDisabled];
        }
        UIColor* bgColor = [Utils colorWithRGBHex: 0x414141];
        UIColor* textColor = [Utils colorWithRGBHex: 0x000000];
        self.backgroundColor = bgColor;
        self.nameLabel.textColor = textColor;
    }
    else
    {
        if (self.iconImageView)
        {
            self.iconImageView.image = [UIImage imageNamed:  self.iconNameDefault];
        }
        UIColor* bgColor = [Utils colorWithRGBHex: 0x414141];
        UIColor* textColor = [Utils colorWithRGBHex: 0xFEFEFE];
        self.backgroundColor = bgColor;
        self.nameLabel.textColor = textColor;
    }
}

@end
