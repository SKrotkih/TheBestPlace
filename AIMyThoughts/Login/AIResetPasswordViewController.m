//
//  AIResetPasswordViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIResetPasswordViewController.h"
#import "MBProgressHUD.h"
#import "AIUser.h"
#import "SSTextField.h"
#import "AINetworkMonitor.h"
#import "Utils.h"
#import "AIPreferences.h"
#import "UIViewController+NavButtons.h"
#import "AILogInManager.h"

@interface AIResetPasswordViewController ()

@property (weak, nonatomic) IBOutlet SSTextField* passwordTextField;
@property (weak, nonatomic) IBOutlet SSTextField* repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton* resetPasswordButton;

@end

@implementation AIResetPasswordViewController

#pragma mark - View Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.resetPasswordButton setTitle: NSLocalizedString(@"Reset Password", nil)
                              forState: UIControlStateNormal];
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [AIPreferences setNavigationBarColor: [Utils colorWithRGBHex: kHexSettingsNavBarColor]
                       forViewController: self];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Main Action

- (IBAction) resetPasswordButtonPressed: (id) sender
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    NSString* password = self.passwordTextField.text;
    NSString* repeatpassword = self.repeatPasswordTextField.text;
    
    if (![password isEqualToString: repeatpassword])
    {
        [self.passwordTextField shake];
        [self.repeatPasswordTextField shake];
        
        return;
    }
    
    AIUser* currentUser = [AIUser currentUser];
    NSString* userId = currentUser.userid;
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AILogInManager sharedInstance] resetPasswordForUserId: userId
                                                   password: password
                                            resultBlock: ^(NSError* anError)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (anError)
         {
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error", nil)
                                                 text: [anError localizedDescription]];
         }
         else
         {
             [self.navigationController popViewControllerAnimated: YES];
         }
     }];
}

#pragma mark - Enable only Portrait mode

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

#pragma mark -

@end
