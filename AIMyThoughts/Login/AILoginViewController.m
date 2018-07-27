//
//  LoginViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AILoginViewController.h"
#import "AIAppDelegate.h"
#import "AIPreferences.h"
#import "Utils.h"
#import "AILogInManager.h"

@interface AILoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton* signInButton;
@property (weak, nonatomic) IBOutlet UIButton* facebookLoginButton;
@property (weak, nonatomic) IBOutlet UIButton* emeilLoginButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* menuBarButtonItem;

@end

@implementation AILoginViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.signInButton setTitle: NSLocalizedString(@"Sign Up", nil)
                       forState: UIControlStateNormal];
    
    [self.facebookLoginButton setTitle: NSLocalizedString(@"Log In with Facebook", nil)
                              forState: UIControlStateNormal];
    
    [self.emeilLoginButton setTitle: NSLocalizedString(@"Log In with E-mail", nil)
                           forState: UIControlStateNormal];
    
    self.title = NSLocalizedString(@"Sign In", nil);
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = self.menuBarButtonItem;
}

- (IBAction) facebookLoginButtonPressed: (id) sender
{
    [[AILogInManager sharedInstance] logInWithFacebookWithViewControoler: self
                                                            resultBlock: ^(AILoginState aLoginState)
     {
         switch (aLoginState) {
             case InternetIsNotPresented:
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"Facebook Log In", nil)
                                                     text: NSLocalizedString(@"Failed to connect to Facebook! Try later again.", nil)];
                 
                 break;
                 
             case OperationHasBeenFinishedSuccessfully:
             {
                 UIStoryboard* signInStoryboard = [UIStoryboard storyboardWithName: @"SignIn"
                                                                            bundle: nil];
                 UIViewController* loginViewController = [signInStoryboard instantiateViewControllerWithIdentifier: @"facebookLoginViewController"];
                 
                 [self.navigationController pushViewController: loginViewController
                                                      animated: YES];
             }
                 
                 break;
                 
             case FailedToRunLogIn:
             {
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"Facebook Log In", nil)
                                                     text: NSLocalizedString(@"Failed to connect to Facebook! Try later again.", nil)];
             }
                 
                 break;
             default:
                 break;
         }
     }];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [AIPreferences setNavigationBarColor: nil
                       forViewController: self];
}

- (void) loggedIn
{
    [AIPreferences setNavigationBarColor: [Utils colorWithRGBHex: kHexLoginNavBarColor]
                       forViewController: self];
    
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction) mainMenuButtonPressed: (id)sender
{
    AIAppDelegate* appDelegate = [AIAppDelegate sharedDelegate];
    [appDelegate toggleLeftSideMenu];
}

#pragma mark Enable only Portrait mode

-(BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
