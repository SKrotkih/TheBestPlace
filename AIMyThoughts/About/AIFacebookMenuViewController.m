//
//  AIFacebookMenuViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/29/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFacebookMenuViewController.h"
#import "AIAppDelegate.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AIPlaceHolderTextView.h"
#import "AINetworkMonitor.h"
#import "MBProgressHUD.h"
#import "SHOmniAuthFacebook.h"
#import <SHActionSheetBlocks.h>
#import <SHAlertViewBlocks.h>
#import <NSArray+SHFastEnumerationProtocols.h>
#import "FBSession.h"
#import "UIViewController+NavButtons.h"

@interface AIFacebookMenuViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet AIPlaceHolderTextView* feedbackTextView;
@property (weak, nonatomic) IBOutlet UIButton *shareFacebookButton;

@end

@implementation AIFacebookMenuViewController
{
    UIBarButtonItem* _doneBarButton;
    BOOL _isSharingContinue;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.feedbackTextView.placeholder = NSLocalizedString(@"Please enter your feedback here...", nil);
    [self.shareFacebookButton setTitle: NSLocalizedString(@"  Share by Facebook", nil)
                              forState: UIControlStateNormal];

    _doneBarButton = [self setRightBarButtonItemType: DoneButtonItem
                                          action: @selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction) shareByFacebook: (id) sender
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        [AIAlertView showAlertWythViewController: self
                                           title: NSLocalizedString(@"Facebook Log In", nil)
                                            text: NSLocalizedString(@"Failed to connect to Facebook! Try later again.", nil)];
        
        return;
    }
    _isSharingContinue = YES;
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [SHOmniAuthFacebook performLoginWithListOfAccounts: ^(NSArray *accounts, SHOmniAuthAccountPickerHandler pickAccountBlock)
     {
         [accounts SH_each: ^(id<account> account)
          {
              pickAccountBlock(account);
              
              if (_isSharingContinue)
              {
                  _isSharingContinue = NO;
                  
                  NSArray* permissions = @[@"email"];
                  [FBSession openActiveSessionWithReadPermissions: permissions
                                                     allowLoginUI: YES
                                                completionHandler: ^(FBSession *session, FBSessionState status, NSError *error)
                   {
                       [MBProgressHUD stopProgressWithAnimation: YES];
                       
                       SLComposeViewController* composeViewController = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeFacebook];
                       [self shareDataWithComposeViewController: composeViewController];
                       
                       return;
                   }];
              }
          }];
     }
                                            onComplete: ^(id<account> account, id response, NSError *error, BOOL isSuccess)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         // NSLog(@"%@", response);
         
         if (_isSharingContinue)
         {
             _isSharingContinue = NO;

             SLComposeViewController* composeViewController = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeFacebook];
             [self shareDataWithComposeViewController: composeViewController];
         }
     }];
}

- (void) shareDataWithComposeViewController: (SLComposeViewController*) aComposeViewController
{
    NSString* text = self.feedbackTextView.text;
    [aComposeViewController setInitialText: text];
    
    UIImage* image = [UIImage imageNamed: @"logo120x120.png"];
    [aComposeViewController addImage: image];
    
    [aComposeViewController setCompletionHandler: ^(SLComposeViewControllerResult result)
     {
         
         switch (result)
         {
             case SLComposeViewControllerResultCancelled:
                 NSLog(@"Post data was canceled!");
                 
                 break;
             case SLComposeViewControllerResultDone:
                 NSLog(@"Post data was finished sucessfully!");
                 
                 break;
                 
             default:
                 
                 break;
         }
         
         [self.navigationController popViewControllerAnimated: YES];
     }];
    
    [self presentViewController: aComposeViewController
                       animated: YES
                     completion: nil];
}

#pragma mark Enable only Portrait mode

- (void) doneButtonPressed: (id) sender
{
    [self.feedbackTextView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark UITextViewDelegate

-(void) textViewDidBeginEditing: (UITextView*) textView
{
    self.navigationItem.rightBarButtonItem = _doneBarButton;
}

-(void) textFieldDidBeginEditing:(UITextField*) textField
{
    self.navigationItem.rightBarButtonItem = _doneBarButton;
}

-(BOOL)shouldAutorotate
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
