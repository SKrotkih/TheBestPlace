//
//  AIRateCompanyView.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/27/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIRateCompanyView.h"

@interface AIRateCompanyView()
@end

@implementation AIRateCompanyView

@synthesize rate = _rate;

- (NSInteger) rate
{
    return _rate;
}

- (void) pressedOnStarNumber: (NSInteger) aStarNumber
{
    NSInteger newRate = aStarNumber;
    
    if (newRate == _rate)
    {
        newRate = 0;
    }

    self.rate = newRate;
}

- (void) setRate: (NSInteger) aRate
{
    if (aRate < 0 || aRate > 3)
    {
        return;
    }

    _rate = aRate;
    
    NSArray* stars = @[self.rateSmile1, self.rateSmile2, self.rateSmile3];

    NSInteger index = 0;
    
    for (UIButton* star in stars)
    {
        if (index + 1 == _rate)
        {
            UIImage* _blackStar = [UIImage imageNamed: [NSString stringWithFormat: @"rate%ld_select.png", (long)(index + 1)]];
            
            [star setImage: _blackStar
                  forState: UIControlStateNormal];
            [star setBackgroundImage: _blackStar
                            forState: UIControlStateNormal];
        }
        else
        {
            UIImage* _whileStar = [UIImage imageNamed: [NSString stringWithFormat: @"rate%ld.png", (long)(index + 1)]];

            [star setImage: _whileStar
                  forState: UIControlStateNormal];
            [star setBackgroundImage: _whileStar
                            forState: UIControlStateNormal];
        }
        
        index++;
    }
}

- (void) shake
{
    [UIView animateWithDuration: 0.3f
                     animations: ^
    {
        self.rateSmile1.transform = CGAffineTransformMakeRotation(M_PI / 2);
        self.rateSmile2.transform = CGAffineTransformMakeRotation(M_PI / 2);
        self.rateSmile3.transform = CGAffineTransformMakeRotation(M_PI / 2);
    }
                     completion: ^(BOOL finished)
    {
        [UIView animateWithDuration: 0.3f
                         animations: ^
        {
            self.rateSmile1.transform = CGAffineTransformMakeRotation(-1.0f * M_PI / 2);
            self.rateSmile2.transform = CGAffineTransformMakeRotation(-1.0f * M_PI / 2);
            self.rateSmile3.transform = CGAffineTransformMakeRotation(-1.0f * M_PI / 2);
        }
                         completion: ^(BOOL finished)
        {
            [UIView animateWithDuration: 0.3f
                             animations: ^
            {
                self.rateSmile1.transform = CGAffineTransformMakeRotation(0.0f);
                self.rateSmile2.transform = CGAffineTransformMakeRotation(0.0f);
                self.rateSmile3.transform = CGAffineTransformMakeRotation(0.0f);
            }];
        }];
    }];
}

@end
