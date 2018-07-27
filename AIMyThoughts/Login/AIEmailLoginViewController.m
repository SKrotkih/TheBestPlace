//
//  AIEmailLoginViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIEmailLoginViewController.h"
#import "AILogInManager.h"
#import "AILoginViewController.h"
#import "AIForgotPasswordViewController.h"
#import "SSTextField.h"
#import "AIUser.h"

@interface AIEmailLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet SSTextField *emailTextField;
@property (weak, nonatomic) IBOutlet SSTextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassword;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@property (weak, nonatomic) IBOutlet UIView *bgEmailLoginView;
@property (weak, nonatomic) IBOutlet UIView *bgEmailLogOutView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

- (IBAction) loginButtonTapHandler: (id) sender;

@end

@implementation AIEmailLoginViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary* underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self.forgotPassword setAttributedTitle: [[NSAttributedString alloc] initWithString: NSLocalizedString(@"Forgot Password?", nil)
                                                                             attributes: underlineAttribute]
                                   forState: UIControlStateNormal];
    
    [self.signupButton setAttributedTitle: [[NSAttributedString alloc] initWithString: NSLocalizedString(@"Want to Sign Up?", nil)
                                                                           attributes: underlineAttribute]
                                 forState: UIControlStateNormal];
    
    self.title = NSLocalizedString(@"E-mail Log In", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey: @"remEmail"])
    {
        self.emailTextField.text = [userDefaults objectForKey: @"remEmail"];
    }
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self setUpCurrentUserState];
}

- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    
    NSString* email = self.emailTextField.text;
    
    if (email && email.length > 0)
    {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject: email forKey: @"remEmail"];
    }
}

- (void) dealloc
{
}

- (void) prepareForSegue: (UIStoryboardSegue*) segue
                  sender: (id)sender
{
    if ([segue.identifier isEqualToString: @"forgotPassword"])
    {
        AIForgotPasswordViewController* destViewController = segue.destinationViewController;
        destViewController.preparedEmail = self.emailTextField.text;
    }
}

- (IBAction) loginButtonTapHandler: (id) sender
{
    AIUser* currentUser = [AIUser currentUser];
    
    if (currentUser)
    {
        [self logOut];
        [self setUpCurrentUserState];
    }
    else
    {
        [self logIn];
    }
}

- (void) setUpCurrentUserState
{
    AIUser* currentUser = [AIUser currentUser];
    
    if (currentUser)
    {
        NSString* userName = [currentUser userName];
        
        [self.loginButton setTitle: NSLocalizedString(@"Log Out", nil)
                          forState: UIControlStateNormal];
        
        self.userNameLabel.text = userName;
        self.bgEmailLoginView.hidden = YES;
        self.bgEmailLogOutView.hidden = NO;
    }
    else
    {
        [self.loginButton setTitle: NSLocalizedString(@"Log In", nil)
                          forState: UIControlStateNormal];
        self.bgEmailLoginView.hidden = NO;
        self.bgEmailLogOutView.hidden = YES;
    }
}

- (void) logOut
{
    [[AILogInManager sharedInstance] logOutWithSuccessBlock: ^{
    }];
}

- (void) logIn
{
    NSString* userid = self.emailTextField.text;
    NSString* passwordText = self.passwordTextField.text;
    
    [[AILogInManager sharedInstance] logInWithUserId: userid
                                            password: passwordText
                                      viewControoler: self
                                     resultBlock: ^(AILoginState aLoginState)
     {
         switch (aLoginState) {
             case UserIdIsWrong:
                 [self.emailTextField shake];
                 
                 break;
             case PasswordIsWrong:
                 [self.passwordTextField shake];
                 
                 break;
             case InternetIsNotPresented:
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"E-mail Log In", nil)
                                                     text: NSLocalizedString(@"Error while connecting to the our server! Please check the Internet connection and try again.", nil)];
                 
                 break;
             case FailedToRunLogIn:
                 
                 break;
             case OperationHasBeenFinishedSuccessfully:
                 [self setUpCurrentUserState];
                 
                 //                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                 //                     NSArray* vcs = self.navigationController.viewControllers;
                 //
                 //                     for (UIViewController* vc in vcs)
                 //                     {
                 //                         if ([vc isKindOfClass: [LoginViewController class]])
                 //                         {
                 //                             [self.navigationController popViewControllerAnimated: NO];
                 //
                 //                             dispatch_async(dispatch_get_main_queue(), ^{
                 //                                 [(LoginViewController*)vc loggedIn];
                 //                             });
                 //
                 //                             break;
                 //                         }
                 //                     }
                 //                 });
                 
                 break;
             default:
                 
                 break;
         }
     }];
}

@end
