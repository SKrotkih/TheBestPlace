//
//  AISendResetViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AISendResetViewController.h"
#import "MBProgressHUD.h"
#import "AIUser.h"
#import "Utils.h"
#import "AIPreferences.h"
#import "UIViewController+NavButtons.h"
#import "AINetworkMonitor.h"
#import "AILogInManager.h"

@interface AISendResetViewController ()

@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation AISendResetViewController

#pragma mark - View life cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
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

- (IBAction) signIn: (id) sender
{
    [self.password resignFirstResponder];

    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    [MBProgressHUD startProgressWithAnimation: YES];

    [[AILogInManager sharedInstance] sendResetPasswordForUserId: _email
                                                       password: _password.text
                                                resultBlock: ^(NSError* anError, AIUser* anUser, NSString* aToken)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (anError)
         {
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error", nil)
                                                 text: [anError localizedDescription]];
         }
         else if (anUser)
         {
             anUser.currentUser = YES;
             
             [[NSUserDefaults standardUserDefaults] setValue: aToken
                                                      forKey: @"token"];
             [[NSUserDefaults standardUserDefaults] setValue: [[NSDate date] dateByAddingTimeInterval: 9500*60]
                                                      forKey: @"expireDate"];
             [[NSUserDefaults standardUserDefaults] setObject: anUser.email
                                                       forKey: @"remEmail"];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
     }];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
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

@end
