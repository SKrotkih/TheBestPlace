//
//  AISignupViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AISignupViewController.h"
#import "AILogInManager.h"
#import "SSTextField.h"
#import "AILoginViewController.h"

@interface AISignupViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar* navBar;
@property (weak, nonatomic) IBOutlet SSTextField* nameTextField;
@property (weak, nonatomic) IBOutlet SSTextField* emailTextField;
@property (weak, nonatomic) IBOutlet SSTextField* passwordTExtField;
@property (weak, nonatomic) IBOutlet SSTextField* mobile;
@property (weak, nonatomic) IBOutlet UIButton* signupButton;
@property (weak, nonatomic) IBOutlet UIView* contentView;

- (IBAction) signupButtonTapHandler: (id) sender;

@end

@implementation AISignupViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    CGSize size = self.contentView.frame.size;
    self.scrollView.contentSize =  size;
    
    self.title = NSLocalizedString(@"Sign Up", nil);
    self.nameTextField.placeholder = NSLocalizedString(@"Name", nil);
    self.emailTextField.placeholder = NSLocalizedString(@"Email", nil);
    self.passwordTExtField.placeholder = NSLocalizedString(@"Password", nil);
    self.mobile.placeholder = NSLocalizedString(@"Mobile", nil);
    [self.signupButton setTitle: NSLocalizedString(@"Register", nil)
                       forState: UIControlStateNormal];
}

- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
}

- (IBAction) signupButtonTapHandler: (id) sender
{
    [self.view endEditing: YES];
    
    NSString* nameUser = self.nameTextField.text;
    NSString* emailUser = self.emailTextField.text;
    NSString* passwordUser = self.passwordTExtField.text;
    NSString* number = self.mobile.text;
    NSCharacterSet* charset = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString* strippedNumber = [[number componentsSeparatedByCharactersInSet: charset]  componentsJoinedByString: @""];
    
    [[AILogInManager sharedInstance] signUpWithUserId: emailUser
                                             password: passwordUser
                                             userName: nameUser
                                               mobile: strippedNumber
                                       viewControoler: self
                                      resultBlock: ^(AILoginState aLoginState)
    {
        switch (aLoginState)
        {
            case UserIdIsWrong:
            {
                [self.emailTextField shake];
            }
                break;
            case UserNameIsWrong:
            {
                [self.nameTextField shake];
            }
                break;
            case PasswordIsWrong:
            {
                [self.passwordTExtField shake];
            }
                break;
            case InternetIsNotPresented:
            case FailedToRunLogIn:
            case LogInCancelled:
                break;
            case OperationHasBeenFinishedSuccessfully:
            {
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
                
            default:
                break;
        }
    }];
}

@end
