//
//  AIPreferences.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 8/19/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import "AIPreferences.h"
#import "Utils.h"

@implementation AIPreferences

+ (UIFont*) fontNormalWithSize: (CGFloat) aFontSize
{
    return [UIFont fontWithName: @"HelveticaNeue-CondensedBold" size: aFontSize];
}

+ (UIFont*) fontBoldWithSize: (CGFloat) aFontSize
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size: aFontSize];
}


+ (void) setNavigationBarColor: (UIColor*) aColor
             forViewController: (UIViewController*) aViewController
{
    UIImage* backgroundImage = nil;
    
    if (aColor)
    {
        backgroundImage = [Utils imageWithColor: aColor];
    }
    else
    {
        backgroundImage = [UIImage new];
    }
    UINavigationBar* navBar = aViewController.navigationController.navigationBar;
    [navBar setBackgroundImage: backgroundImage
                 forBarMetrics: UIBarMetricsDefault];
}


@end
