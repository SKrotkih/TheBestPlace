//
//  AIAppDelegate.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIAppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MFSideMenuContainerViewController.h"
#import "AIMainMenuViewController.h"
#import "AIFoursquareAdapter.h"
#import "AILoginViewController.h"
#import "AIHomeViewController.h"
#import "LUKeychainAccess.h"

@implementation AIAppDelegate
{
    MFSideMenuContainerViewController* _container;
}

+ (AIAppDelegate*) sharedDelegate
{
	return (AIAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL) application: (UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    
    [self saveStatusBarState];
    
    [self configureNavBarBackground];
    
    [[AIFoursquareAdapter sharedInstance] setupFoursquare];
    
    BOOL retValue = [[FBSDKApplicationDelegate sharedInstance] application: application
                                             didFinishLaunchingWithOptions: launchOptions];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                         bundle: nil];
    AIMainMenuViewController* leftMenuVC = [storyboard instantiateViewControllerWithIdentifier: @"leftMenuNavController"];

//    UIStoryboard* signInStoryboard = [UIStoryboard storyboardWithName: @"SignIn"
//                                                         bundle: nil];
//    UINavigationController* loginNavController = [signInStoryboard instantiateViewControllerWithIdentifier: @"LoginNavController"];
    
  	self.navController = [self navigationController];
    
    _container = [MFSideMenuContainerViewController containerWithCenterViewController: self.navigationController
                                                               leftMenuViewController: leftMenuVC
                                                              rightMenuViewController: nil ];
    self.window.tintColor = [UIColor blackColor];
    self.window.rootViewController = _container;
    [self.window makeKeyAndVisible];
    
    return retValue;
}

- (BOOL) application: (UIApplication*) application
             openURL: (NSURL*) url
   sourceApplication: (NSString*) sourceApplication
          annotation: (id) annotation
{
    BOOL isFoursquareHandledOk = [[AIFoursquareAdapter sharedInstance] handleURL: url];
    return isFoursquareHandledOk || [[FBSDKApplicationDelegate sharedInstance] application: application
                                                                                   openURL: url
                                                                         sourceApplication: sourceApplication
                                                                                annotation: annotation];
}

#pragma mark Application Lifecycle

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Menu

- (void) toggleLeftSideMenu
{
    [_container toggleLeftSideMenuCompletion: ^{
        
    }];
}

- (void) toggleRightSideMenu
{
    [_container toggleRightSideMenuCompletion: ^{
        
    }];
}

- (void) setUpCenterViewController: (NSArray*) aControllers
{
    UINavigationController* navigationController = _container.centerViewController;
    navigationController.viewControllers = aControllers;
    [_container setMenuState: MFSideMenuStateClosed];
}

- (UIViewController*) centerViewController
{
    return _container.centerViewController;
}

#pragma mark -

- (UINavigationController*) navigationController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                         bundle: nil];
    UINavigationController* navController = [storyboard instantiateViewControllerWithIdentifier: @"navController"];
    
    return navController;
}

- (void) configureNavBarBackground
{
    [[UINavigationBar appearance] setBackgroundImage: [UIImage imageNamed: @"navigation-bar-background"]
                                       forBarMetrics: UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage: [[UIImage alloc] init]];
}

#pragma mark Present ModalViewController

- (void) presentModalViewController: (UIViewController*) aViewController
{
	UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: aViewController];
	UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController* controller = [self topViewController: keyWindow.rootViewController];
	[controller presentViewController: navigationController
                             animated: YES
                           completion: nil];
    
// Note! for Dissmiss:
//    [loginViewController.presentingViewController dismissViewControllerAnimated: YES
//                                                                     completion: nil];
    
}

- (UIViewController*) topViewController: (UIViewController*) rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass: [UINavigationController class]])
    {
        UINavigationController* navigationController = (UINavigationController*) rootViewController.presentedViewController;
        UIViewController* lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController: lastViewController];
    }
    
    UIViewController* presentedViewController = (UIViewController*) rootViewController.presentedViewController;
    
    return [self topViewController: presentedViewController];
}


- (UIImageView*) takeWindowScreenshot
{
    UIGraphicsBeginImageContext(self.window.bounds.size);
    [self.window.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView* screenShot = [[UIImageView alloc] initWithImage: image];
    
    return screenShot;
}

#pragma mark - Status Bar State

- (void) saveStatusBarState
{
    BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool: statusBarHidden
               forKey: kStatusBarHiddenDefaultValue];
    [defaults synchronize];
}

- (void) restoreStatusBarState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL statusBarHidden = [defaults boolForKey: kStatusBarHiddenDefaultValue];
    [[UIApplication sharedApplication] setStatusBarHidden: statusBarHidden];
}

#pragma mark -


@end
