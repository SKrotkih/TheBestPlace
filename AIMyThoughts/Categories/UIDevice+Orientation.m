//
//  UIDevice-Orientation.m
//  ePublishing
//
//  Created by Sergey Krotkih on 8/18/13.
//
//

#import "UIDevice+Orientation.h"

@implementation UIDevice (Orientation)

- (CGRect) screenFrame
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds;
    BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    
    //implicitly in Portrait orientation.
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
    {
        CGRect temp = CGRectZero;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;
    }
    
    if(!statusBarHidden)
    {
        CGFloat statusBarHeight = [self statusBarHeight];
        fullScreenRect.size.height -= statusBarHeight;
    }
    
    return fullScreenRect;
}

- (BOOL) isLandscape
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return (UIDeviceOrientationIsLandscape(orientation));
}

- (BOOL) isPortrait
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return (UIDeviceOrientationIsPortrait(orientation));
}

- (CGFloat) statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    
    return MIN(statusBarSize.width, statusBarSize.height);
}


@end
