//
//  AIAppDelegate.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIAppDelegate : UIResponder <UIApplicationDelegate>

- (void) toggleLeftSideMenu;
- (void) toggleRightSideMenu;
- (void) setUpCenterViewController: (NSArray*) aControllers;
- (UIViewController*) centerViewController;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController* navController;

+ (AIAppDelegate*) sharedDelegate;
- (void) configureNavBarBackground;
- (void) presentModalViewController: (UIViewController*) aViewController;
- (UIImageView*) takeWindowScreenshot;
- (void) restoreStatusBarState;

@end
