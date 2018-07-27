//
//  AIForgotPasswordViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIForgotPasswordViewController.h"
#import "MBProgressHUD.h"
#import "AISendResetViewController.h"
#import "SSTextField.h"
#import "AINetworkMonitor.h"
#import "Utils.h"
#import "AIEmailManager.h"
#import "NSString+Validator.h"
#import "AILogInManager.h"

static const BOOL kSendEmailByInternalMailer = YES;

@interface AIForgotPasswordViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel* enterEmailText;
@property (weak, nonatomic) IBOutlet SSTextField* emailTextField;
@property (weak, nonatomic) IBOutlet UIButton* emailButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;


- (IBAction) sendPasswordOnEmail: (id) sender;

@end

@implementation AIForgotPasswordViewController
{
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.emailButton setTitle: NSLocalizedString(@"E-mail temporary password", nil)
                      forState: UIControlStateNormal];
    self.enterEmailText.text = NSLocalizedString(@"Enter your email address and we will send an email with your temporary password.", nil);
    self.emailTextField.text = self.preparedEmail;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    CGSize size = self.contentView.frame.size;
    self.scrollView.contentSize = size;
}

- (IBAction) sendPasswordOnEmail: (id) sender
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    NSString* email = self.emailTextField.text;
    
    if (![email validateEmail] || ![email validateNonEmpty])
    {
        [self.emailTextField shake];
        
        return;
    }
    
    [self.emailTextField resignFirstResponder];
    
    NSString* messageTemplate =  NSLocalizedString(@"Your password is: ", nil);
    NSString* subject =  NSLocalizedString(@"The Best Place. The reminder of your password.", nil);
    NSString* userName = @"";
    
    if (kSendEmailByInternalMailer)
    {
        [MBProgressHUD startProgressWithAnimation: YES];
        
        [[AILogInManager sharedInstance] getPasswordForEmail: email
                                             resultBlock: ^(NSError* anError, NSString* password)
         {
             [MBProgressHUD stopProgressWithAnimation: YES];
             
             if (anError)
             {
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"Error", nil)
                                                     text: [anError localizedDescription]];
                 return;
             }
             
             NSString* stringFormat = NSLocalizedString(@"%@ %@\nThanks for using The Best Place!", nil);
             
             [[AIEmailManager sharedInstance] sendMailBySKPSMTPMessageWithEmail: email
                                                                        to_name: userName
                                                                        subject: subject
                                                                        message: [NSString stringWithFormat: stringFormat, messageTemplate, password]
                                                                  isMessageHTML: NO
                                                                    resultBlock: ^(NSError* anError)
              {
                  if (anError)
                  {
                      [AIAlertView showAlertWythViewController: self
                                                         title: NSLocalizedString(@"Failed to send email", nil)
                                                          text: [anError localizedDescription]];
                  }
                  else
                  {
                      [AIAlertView showAlertWythViewController: self
                                                         title: NSLocalizedString(@"Your password was succesfully reset. Please check your email.", nil)
                                                          text: @""];
                  }
              }];
         }];
    }
    else
    {
        [MBProgressHUD startProgressWithAnimation: YES];
        
        [[AILogInManager sharedInstance] sendPasswordOnEmail: email
                                                    userName: userName
                                                     subject: subject
                                             messageTemplate: messageTemplate
                                             resultBlock: ^(NSError* anError)
         {
             [MBProgressHUD stopProgressWithAnimation: YES];
             
             if (anError)
             {
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"Failed to send email", nil)
                                                     text: [anError localizedDescription]];
             }
             else
             {
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"Your password was succesfully reset. Please check your email.", nil)
                                                     text: @""];
             }
         }];
    }
}

- (void) alertView: (UIAlertView*) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
    AISendResetViewController* controller = [[AISendResetViewController alloc] initWithNibName: @"AISendResetViewController"
                                                                                        bundle: nil];
    [self.navigationController pushViewController: controller
                                         animated: YES];
    controller.email = self.emailTextField.text;
}

@end
