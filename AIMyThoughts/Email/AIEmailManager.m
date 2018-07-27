//
//  AIEmailManager.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 7/31/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIEmailManager.h"
#import <MessageUI/MessageUI.h>
#import "SKPSMTPMessage.h"
#import "MBProgressHUD.h"
#import "UIAlertView+SHAlertViewBlocks.h"
#import "AIUser.h"

NSString* const kFromEmail =    @"thebestplace2015@gmail.com";
NSString* const kRelayHost =    @"smtp.gmail.com";
NSString* const kAuthUsername = @"thebestplace2015@gmail.com";
NSString* const kAuthPassword = @"123thebestplace2015123";

@interface AIEmailManager()  <MFMailComposeViewControllerDelegate, SKPSMTPMessageDelegate>

@property (nonatomic, weak) UIViewController* parentViewController;
@property (nonatomic, copy) void(^emailSentCallback)(NSError*);

@end

@implementation AIEmailManager
{
    SKPSMTPMessage* _smtpMessage;
}

+ (AIEmailManager*) sharedInstance
{
    static AIEmailManager* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[AIEmailManager alloc] init];
    });
    
    return instance;
}

#pragma mark - Send Email With Invite to join US

- (void) sendEmailWithInviteWithEmail: (NSString*) anEmail
                           friendName: (NSString*) aFriendName
{
    AIUser* currentUser = [AIUser currentUser];
    NSString* myName = currentUser.userName;
    
    [[UIAlertView SH_alertViewWithTitle: NSLocalizedString(@"Confirm please", nil)
                             andMessage: [NSString stringWithFormat: NSLocalizedString(@"Send invitation to %@ to join to us by email: %@", nil), aFriendName, anEmail]
                               buttonTitles: @[@"OK"]
                                cancelTitle: NSLocalizedString(@"Cancel", nil)
                                  withBlock: ^(NSInteger theButtonIndex)
      {
          if (theButtonIndex == 1)
          {
              NSString* subject = [NSString stringWithFormat: @"%@ has invited you to try 'The Best Place'", myName];
              NSString* body = [NSString stringWithFormat: @"<h1>%@ has invited you to try 'The Best Place'.</h1> Using 'The Best Place', you will be able to anonymously leave feedbacks about places which you visited. After you sign up, you'll be able to stay connected with friends, view places which they visited and their feedbacks about these places. <a href=\"http://itunes.com/apps/TheBestPlace\">Get The App</a>", myName];
              
              [[AIEmailManager sharedInstance] sendMailBySKPSMTPMessageWithEmail: anEmail
                                                                         to_name: aFriendName
                                                                         subject: subject
                                                                         message: body
                                                                   isMessageHTML: YES
                                                                     resultBlock: ^(NSError* anError){
                                                                            if (anError)
                                                                            {
                                                                                [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"Failed to send email", nil)
                                                                                                             text: [anError localizedDescription]];
                                                                            }
                                                                            else
                                                                            {
                                                                                [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"Congrats!", nil)
                                                                                                             text: NSLocalizedString(@"Inviting was sent successfully", nil)];
                                                                            }
                                                                        }];
          }
      }] show];
}

#pragma mark Another way: By email Composer

- (void) sendInviteEmailTo: (NSString*) eMail
                      name: (NSString*) aName
            viewController: (UIViewController*) aViewController
{
    self.parentViewController = aViewController;
    
    // Email Subject
    NSString* emailTitle = [NSString stringWithFormat: @"%@ has invited you to try The Best Place", aName];
    
    // Email Content
    NSString* messageBody = [NSString stringWithFormat: @"<h1>%@ has invited you to try The Best Place.</h1> Using The Best Place, you will be able to anonymously leave feedbacks about places which you visited. After you sign up, you'll be able to stay connected with friends, view places which they visited and their feedbacks about these places. <a href=\"http://itunes.com/apps/thoughtsbook\">Get The App</a>", aName];
    
    // To address
    eMail = (eMail == nil) ? @"" : eMail;
    NSArray* toRecipents = [NSArray arrayWithObject: eMail];
    //NSArray* toRecipents = [NSArray arrayWithObject: @"svmp@ukr.net"];
    
    MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
    mc.navigationBar.tintColor = [UIColor whiteColor];
    mc.mailComposeDelegate = self;
    [mc setSubject: emailTitle];
    [mc setMessageBody: messageBody
                isHTML: YES];
    [mc setToRecipients: toRecipents];
    
    // Present mail view controller on screen
    [self.parentViewController presentViewController: mc
                                            animated: YES
                                          completion: NULL];
    
}

- (void) mailComposeController: (MFMailComposeViewController*) controller
           didFinishWithResult: (MFMailComposeResult) result
                         error: (NSError*) error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            
            break;
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        }
            
            break;
        default:
            
            break;
    }
    
    // Close the Mail Interface
    [self.parentViewController dismissViewControllerAnimated: YES
                                                  completion: NULL];
}

#pragma mark - Send email by SKPSMTPMessage

// http://stackoverflow.com/questions/10914020/iphone-to-send-email-using-smtp-server
// https://github.com/kailoa/iphone-smtp
- (void) sendMailBySKPSMTPMessageWithEmail: (NSString*) toEmail
                                   to_name: (NSString*) anUserName
                                   subject: (NSString*) subject
                                   message: (NSString*) message
                             isMessageHTML: (BOOL) anIsMessageHTML
                               resultBlock: (void(^)(NSError*)) aResultBlock
{
    self.emailSentCallback = aResultBlock;
    _smtpMessage = [[SKPSMTPMessage alloc] init];
    _smtpMessage.fromEmail = kFromEmail;
    _smtpMessage.relayHost = kRelayHost;
    _smtpMessage.requiresAuth = YES;
    _smtpMessage.login = kAuthUsername;
    _smtpMessage.pass = kAuthPassword;
    _smtpMessage.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
    
    _smtpMessage.toEmail = toEmail;
    _smtpMessage.subject = subject;
    _smtpMessage.delegate = self;
    
    NSMutableArray* parts_to_send = [NSMutableArray array];
    
    if (message.length > 0)
    {
        NSDictionary* plain_text_part = @{kSKPSMTPPartContentTypeKey: [NSString stringWithFormat: @"text/%@", anIsMessageHTML ? @"html": @"plain"],
                                          kSKPSMTPPartMessageKey: message,
                                          kSKPSMTPPartContentTransferEncodingKey: @"8bit"};
        [parts_to_send addObject: plain_text_part];
    }
    
    _smtpMessage.parts = parts_to_send;
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    if ([_smtpMessage send])
    {
        NSLog(@"Email '%@' to %@ was sent successfully.", subject, toEmail);
    }
    else
    {
        NSLog(@"Failed to send Email '%@' to %@.", subject, toEmail);
    }
}

#pragma mark SKPSMTPMessageDelegate

- (void) messageSent: (SKPSMTPMessage*) message
{
    [MBProgressHUD stopProgressWithAnimation: YES];
    
    _smtpMessage = nil;
    
    if (self.emailSentCallback)
    {
        self.emailSentCallback(nil);
    }
}

- (void) messageFailed: (SKPSMTPMessage*) message error: (NSError*) error
{
    [MBProgressHUD stopProgressWithAnimation: YES];
    
    _smtpMessage = nil;
    
    if (self.emailSentCallback)
    {
        self.emailSentCallback(error);
    }
}

- (void) messageState: (SKPSMTPState) messageState
{
}

#pragma mark -

@end
