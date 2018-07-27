//
//  UIView+Shake.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/22/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "UIView+Shake.h"

@implementation UIView (Shake)

+ (void) shakeView: (UIView*) view
{
    [UIView animateWithDuration: 0.1
                          delay: 0
                        options: UIViewAnimationOptionLayoutSubviews
                     animations: ^
     {
         CGRect _frame = view.frame;
         _frame.origin.x = _frame.origin.x - 10.0f;
         view.frame = _frame;
     }
                     completion: ^(BOOL finished)
     {
         [UIView animateWithDuration: 0.1
                               delay: 0
                             options: UIViewAnimationOptionLayoutSubviews
                          animations: ^
          {
              CGRect _frame = view.frame;
              _frame.origin.x = _frame.origin.x + 15.0f;
              view.frame = _frame;
          }
                          completion: ^(BOOL finished)
          {
              [UIView animateWithDuration: 0.1
                                    delay: 0
                                  options: UIViewAnimationOptionLayoutSubviews
                               animations: ^
               {
                   CGRect _frame = view.frame;
                   _frame.origin.x = _frame.origin.x - 5.0f;
                   view.frame = _frame;
               }
                               completion: ^(BOOL finished)
               {
                   
               }];
          }];
     }];
}

@end
