//
//  AISharingButton.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 9/26/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import "AISharingButton.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "AIFoursquareAdapter.h"
#import "AINetworkMonitor.h"

#import "SHActionSheetBlocks.h"
#import "SHAlertViewBlocks.h"

const NSString* kHomeWebPageApplication = @"http://thebestplace.krizantos.com";

@interface AISharingButton () <FBSDKSharingDelegate>

@end

@implementation AISharingButton
{
    
}

#pragma mark - Object Lifecycle

- (instancetype) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self configureButton];
    }

    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];

    [self configureButton];
}

- (void) configureButton
{
    [self addTarget: self
             action: @selector(touchUpInsideHandler:)
   forControlEvents: UIControlEventTouchUpInside];
}

- (void) touchUpInsideHandler: (id) sender
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    switch (self.typeOfSharing)
    {
        case Facebook:
            [self shareOnFacebook];
            
            break;
        case Twitter:
            [self shareOnTwitter];

            break;
        case Foursquare:
            [self shareOnFoursquare];

            break;
        default:
            break;
    }
}

- (NSString*) text
{
    NSString* text = nil;
    
    if (self.shareTextField)
    {
        text = self.shareTextField.text;
    }
    else if (self.shareTexView)
    {
        text = self.shareTexView.text;
    }
    
    if (text == nil || text.length == 0)
    {
        [AIAlertView showAlertWythViewController: self.viewController
                                           title: NSLocalizedString(@"Warning", nil)
                                            text: NSLocalizedString(@"Please enter your thoughts about this place!", nil)];
    }
    
    return text;
}

#pragma mark - Foursquare

- (void) shareOnFoursquare
{
    NSString* venueId = self.venueId;
    NSString* text = self.text;
    
    if (venueId == nil || venueId.length == 0 || text == nil || text.length == 0)
    {
        return;
    }
    //NSDictionary* userData = @{@"text": self.text, @"url": kHomeWebPageApplication, @"venueId": venueId};
    NSDictionary* userData = @{@"text": self.text, @"venueId": venueId};
    [[AIFoursquareAdapter sharedInstance] shareFeedbackWithUserData: userData];
}

#pragma mark - Twitter

- (void) shareOnTwitter
{
    if (![SLComposeViewController isAvailableForServiceType: SLServiceTypeTwitter])
    {
        [AIAlertView showAlertWythViewController: self.viewController
                                           title: NSLocalizedString(@"Service is not available", nil)
                                            text: NSLocalizedString(@"You should log in to Twitter in Settings app.", nil)];
        return;
    }
    NSString* text = self.text;

    if (text == nil || text.length == 0)
    {
        return;
    }
    SLComposeViewController* composeViewController = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeTwitter];
    [composeViewController setInitialText: text];
    
    //NSURL* imageURL = self.photoURL;
    //NSData* imageData = [NSData dataWithContentsOfURL: imageURL];
    //UIImage* image = [UIImage imageWithData: imageData];
    UIImage* image = [UIImage imageNamed: @"logo120x120.png"];
    [composeViewController addImage: image];
    NSURL* sharingURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@", kHomeWebPageApplication]];
    [composeViewController addURL: sharingURL];
    
    [composeViewController setCompletionHandler: ^(SLComposeViewControllerResult result)
     {
         
         switch (result)
         {
             case SLComposeViewControllerResultCancelled:
                 NSLog(@"Post data was canceled!");
                 
                 break;
             case SLComposeViewControllerResultDone:
                 [AIAlertView showAlertWythViewController: self.viewController
                                                    title: NSLocalizedString(@"Share on Twitter", nil)
                                                     text: NSLocalizedString(@"Post data was finished sucessfully!", nil)];
                 
                 break;
                 
             default:
                 
                 break;
         }
     }];
    [self.viewController presentViewController: composeViewController
                                      animated: YES
                                    completion: nil];
}

#pragma mark Share with Facebook

- (void) shareOnFacebook
{
    NSString* text = self.text;
    if (text == nil || text.length == 0)
    {
        return;
    }
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    FBSDKShareLinkContent* content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = self.photoURL;
    
//  Assignment to readonly property
//    content.contentTitle = @"";
//    content.contentDescription = text;
    
    shareDialog.shareContent = content;
    shareDialog.delegate = self;
    [shareDialog show];
}

#pragma mark - FBSDKSharingDelegate

- (void) sharer: (id<FBSDKSharing>) sharer didCompleteWithResults: (NSDictionary*) results
{
    NSLog(@"completed share:%@", results);

    [AIAlertView showAlertWythViewController: self.viewController
                                       title: NSLocalizedString(@"Share on Facebook", nil)
                                        text: NSLocalizedString(@"Post data was finished sucessfully!", nil)];
}

- (void) sharer: (id<FBSDKSharing>) sharer didFailWithError: (NSError*) error
{
    NSLog(@"sharing error:%@", error);

    NSString* message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ? : @"There was a problem sharing, please try again later.";
    NSString* title = error.userInfo[FBSDKErrorLocalizedTitleKey] ? : @"Oops!";

    [AIAlertView showAlertWythViewController: self.viewController
                                       title: title
                                        text: message];
}

- (void) sharerDidCancel: (id<FBSDKSharing>) sharer
{
    NSLog(@"share cancelled");
}

@end
