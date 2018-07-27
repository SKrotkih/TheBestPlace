//
//  AIRateCompanyView.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/27/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIRateCompanyView : UIView
{
    NSInteger _rate;
}

@property (weak, nonatomic) UIButton* rateSmile1;
@property (weak, nonatomic) UIButton* rateSmile2;
@property (weak, nonatomic) UIButton* rateSmile3;

@property (nonatomic, assign) NSInteger rate;

- (void) pressedOnStarNumber: (NSInteger) aStarNumber;

- (void) shake;

@end
