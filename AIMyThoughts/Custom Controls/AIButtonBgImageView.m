//
//  AIButtonBgImageView.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/24/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIButtonBgImageView.h"
#import "Utils.h"

@implementation AIButtonBgImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCoder: (NSCoder*) aDecoder
{
    if ((self = [super initWithCoder: aDecoder]))
    {
        
//        UIColor* bgColor = [Utils colorWithRGBHex: 0xFC630A];
//        UIImage* backgroundImage = [Utils imageWithColor: bgColor];
//        self.image = backgroundImage;
        
        self.image = [UIImage imageNamed: @"navigation-bar-background"];
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

@end
