//
//  UIDevice-Orientation.h
//  ePublishing
//
//  Created by Sergey Krotkih on 8/18/13.
//
//

#import <UIKit/UIKit.h>

@interface UIDevice (Orientation)

@property (nonatomic, readonly) BOOL isLandscape;
@property (nonatomic, readonly) BOOL isPortrait;
@property (nonatomic, readonly) CGRect screenFrame;
@property (nonatomic, readonly) CGFloat statusBarHeight;

@end
