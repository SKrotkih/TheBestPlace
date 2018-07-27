//
//  UIImage+ScaleToFit.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/6/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ScaleToDit)

- (UIImage*) imageByScalingProportionallyToSize: (CGSize) targetSize;

@end
