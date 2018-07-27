//
//  AIUserProfileViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIUserProfileViewController.h"
#import "AILogInManager.h"
#import "AIAppDelegate.h"
#import "MBProgressHUD.h"
#import "AIUser.h"
#import "AGMedallionView+DownloadImage.h"
#import "Utils.h"
#import "AILoginViewController.h"
#import "AINetworkMonitor.h"

#import "SHActionSheetBlocks.h"
#import "SHAlertViewBlocks.h"
#import "NSArray+SHFastEnumerationProtocols.h"
#import "AGMedallionView.h"
#import "AIPreferences.h"
#import "UIViewController+NavButtons.h"

@interface AIUserProfileViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView* bgButtonImageView;
@property (weak, nonatomic) IBOutlet AGMedallionView* photoView;
@property (weak, nonatomic) IBOutlet UIButton* logInButton;
- (IBAction) logIn: (id) sender;
- (void) logIn;

@end

@implementation AIUserProfileViewController
{
    BOOL _isLogged;
    BOOL _isLockedLoginButton;
    AIUser* _currentUser;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Facebook";
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
    
    if ([self respondsToSelector: @selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    _isLockedLoginButton = NO;
    
    self.bgButtonImageView.layer.masksToBounds = YES;
    self.bgButtonImageView.layer.cornerRadius = 8.0f;
    
    [self hideButtonIfNeeded: YES];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [AIPreferences setNavigationBarColor: [Utils colorWithRGBHex: kHexFacebookAccountNavBarColor]
                       forViewController: self];
    
    [self showUserData];
    
    if (_isLogged)
    {
        [self hideButtonIfNeeded: NO];
    }
}

- (void) hideButtonIfNeeded: (BOOL) isNeededHide
{
    self.logInButton.hidden = isNeededHide;
    self.bgButtonImageView.hidden = isNeededHide;
}

- (void) showUserData
{
    _currentUser = [AIUser currentUser];
    
    if (_currentUser != nil && _currentUser.fb_id.length > 0)
    {
        self.nameLabel.text = [NSString stringWithFormat: @"%@ %@", _currentUser.firstname, _currentUser.lastname];
        [self.photoView asyncDownloadImageURL: _currentUser.photo_prefix
                        placeholderImageNamed: @"profile-icon"];
        [self.logInButton setTitle: NSLocalizedString(@"Log Out", nil)
                          forState: UIControlStateNormal];
        _isLogged = YES;
    }
    else
    {
        self.nameLabel.text = @"";
        self.photoView.image = nil;
        [self.logInButton setTitle: NSLocalizedString(@"Log In", nil)
                          forState: UIControlStateNormal];
        _isLogged = NO;
    }
}

- (IBAction) logIn: (id) sender
{
    if (!_isLockedLoginButton)
    {
        _isLockedLoginButton = YES;
        
        if (_isLogged)
        {
            [self logOut];
        }
        else
        {
            [self logIn];
        }
    }
}

- (void) logOut
{
    [[AILogInManager sharedInstance]  logOutWithSuccessBlock: ^(){
        [self showUserData];
        _isLockedLoginButton = NO;
        
        [self.navigationController popViewControllerAnimated: YES];
    }];
}

- (void) logIn
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
                [self showUserData];
                
                _isLockedLoginButton = NO;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    NSArray* vcs = self.navigationController.viewControllers;
                    
                    for (UIViewController* vc in vcs)
                    {
                        if ([vc isKindOfClass: [AILoginViewController class]])
                        {
                            [self.navigationController popViewControllerAnimated: NO];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [(AILoginViewController*)vc loggedIn];
                            });
                            
                            break;
                        }
                    }
                });
            }
                
                break;
                
            case FailedToRunLogIn:
            {
                [AIAlertView showAlertWythViewController: self
                                                   title: NSLocalizedString(@"Facebook Log In", nil)
                                                    text: NSLocalizedString(@"Failed to connect to Facebook! Try later again.", nil)];
                
                _isLockedLoginButton = NO;
            }
                
                break;
            default:
                break;
        }
    }];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark UIAlertViewDelegate

- (void) alertView: (UIAlertView*) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    [self.navigationController popViewControllerAnimated: YES];
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
