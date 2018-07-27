//
//  AIPreferences.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 8/19/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIPreferences : NSObject

+ (UIFont*) fontNormalWithSize: (CGFloat) aFontSize;
+ (UIFont*) fontBoldWithSize: (CGFloat) aFontSize;
+ (void) setNavigationBarColor: (UIColor*) aColor
             forViewController: (UIViewController*) aViewController;

@end
