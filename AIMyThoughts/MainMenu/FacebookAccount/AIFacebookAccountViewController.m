//
//  AIFacebookAccountViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFacebookAccountViewController.h"
#import "AILogInManager.h"
#import "AILoginViewController.h"
#import "AIPreferences.h"
#import "AIUser.h"
#import "Utils.h"
#import "AINetworkMonitor.h"
#import "AGMedallionView.h"
#import "AGMedallionView+DownloadImage.h"
#import "UIViewController+NavButtons.h"

@interface AIFacebookAccountViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectedToLabel;

@property (weak, nonatomic) IBOutlet UIImageView* bgButtonImageView;
@property (weak, nonatomic) IBOutlet AGMedallionView* photoView;

@property (weak, nonatomic) IBOutlet UIButton* logInButton;
@property (weak, nonatomic) IBOutlet UILabel *shareMyThoughtsLabe;
@property (weak, nonatomic) IBOutlet UISwitch *TimalineSwitch;

- (IBAction) logIn: (id) sender;

- (void) logIn;

@end

@implementation AIFacebookAccountViewController
{
    BOOL _isLogged;
    BOOL _isLockedLoginButton;
    AIUser* _currentUser;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector: @selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = @"Facebook account";
    
    [self setLeftBarButtonItemType: BackButtonItem
                        action: @selector(backButtonPressed:)];
    
    self.connectedToLabel.text = NSLocalizedString(@"Connected to:", nil);
    
    self.shareMyThoughtsLabe.text = NSLocalizedString(@"Share my thoughts, like to my Timeline", nil);
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
    
    [self hideButtonIfNeeded: NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [AIPreferences setNavigationBarColor: nil
                       forViewController: self];
}

#pragma mark -
#pragma mark Log In/Log Out

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

- (void) logOut
{
    [[AILogInManager sharedInstance]  logOutWithSuccessBlock: ^(){
        [self showUserData];
        _isLockedLoginButton = NO;
        
        [self.navigationController popViewControllerAnimated: YES];
    }];
}

#pragma mark -
#pragma mark Show User Data

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
        
        self.nameLabel.hidden = NO;
        self.connectedToLabel.hidden = NO;
        self.photoView.hidden = NO;
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
        
        self.nameLabel.hidden = YES;
        self.connectedToLabel.hidden = YES;
        self.photoView.hidden = YES;
        
        [self.logInButton setTitle: NSLocalizedString(@"Log In", nil)
                          forState: UIControlStateNormal];
        _isLogged = NO;
    }
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
