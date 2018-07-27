//
//  AIBaseButtonBgImageView.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/24/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIBaseButtonBgImageView.h"

@implementation AIBaseButtonBgImageView

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
        self.image = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8.0f;
    }

    return self;
}

@end
