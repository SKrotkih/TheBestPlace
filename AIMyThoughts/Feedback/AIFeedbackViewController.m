//
//  AIFeedbackViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFeedbackViewController.h"
#import "AIRateCompanyView.h"
#import "AIFileManager.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AIFeedback.h"
#import "AIFeedbackPhotoImageView.h"
#import "AIApplicationServer.h"
#import "AIPlaceHolderTextView.h"
#import "AIAppDelegate.h"
#import "MBProgressHUD.h"
#import "Utils.h"
#import "AICompanyProfileViewController.h"
#import "AINetworkMonitor.h"
#import "SHActionSheetBlocks.h"
#import "SHAlertViewBlocks.h"
#import "NSArray+SHFastEnumerationProtocols.h"
#import "AIHomeViewController.h"
#import "AIUser.h"
#import "AIChangeInLocalDataTrace.h"
#import "AIPreferences.h"
#import "UIViewController+NavButtons.h"
#import "AISharingButton.h"

@interface AIFeedbackViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel* wahatAreYouThoughtLabel;
@property (weak, nonatomic) IBOutlet UILabel* companyNameLabel;

@property (weak, nonatomic) IBOutlet AIRateCompanyView* rateView;

@property (weak, nonatomic) IBOutlet AIPlaceHolderTextView* feedbackTextView;

@property (weak, nonatomic) IBOutlet UILabel* addPhotoLabel;
@property (weak, nonatomic) IBOutlet AIFeedbackPhotoImageView* addPhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton* changeMenuPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton* addPhotoButton;

@property (weak, nonatomic) IBOutlet UILabel* anonymousLabel;
@property (weak, nonatomic) IBOutlet UISwitch* anonymousSwitch;

@property (weak, nonatomic) IBOutlet UIImageView* buttonBgImageView;
@property (weak, nonatomic) IBOutlet UIButton* addFeedbackButton;

@property (weak, nonatomic) IBOutlet AISharingButton* facebookButton;
@property (weak, nonatomic) IBOutlet AISharingButton* twitterButton;
@property (weak, nonatomic) IBOutlet AISharingButton* foursquareButton;
@property (weak, nonatomic) IBOutlet UIButton *foursquareLogoButton;

@property (weak, nonatomic) IBOutlet UIButton* rateSmile1;
@property (weak, nonatomic) IBOutlet UIButton* rateSmile2;
@property (weak, nonatomic) IBOutlet UIButton* rateSmile3;

@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *whatAreYouThoughtLabel;

@property (weak, nonatomic) IBOutlet UIView *saveThoughtsButtonView;

@property (nonatomic, copy) NSString* userEmail;

@end

@implementation AIFeedbackViewController
{
    AIPhotoMakerController* _photoMaker;
    UIBarButtonItem* _doneBarButton;
    BOOL _isFeedbackSaved;
    BOOL _needSavePhoto;
}

#pragma mark UIView lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Thoughts Page", @"Thoughts Page");
    
    self.rateView.rateSmile1 = self.rateSmile1;
    self.rateView.rateSmile2 = self.rateSmile2;
    self.rateView.rateSmile3 = self.rateSmile3;
    self.shareLabel.text = NSLocalizedString(@"SHARE", nil);
    self.rateView.rate = [self.feedback.rate integerValue];
    self.feedbackTextView.text = self.feedback.text;
    self.feedbackTextView.placeholder = NSLocalizedString(@"Please enter your feedback here...", nil);
    self.whatAreYouThoughtLabel.text = NSLocalizedString(@"What are your thoughts about", nil);
    
    [self setUpOfButtonsState];
    [self setUpOfNavigateButtons];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(sharingStatus)
                                                 name: ACAccountStoreDidChangeNotification
                                               object: nil];
    [[AIAppDelegate sharedDelegate] restoreStatusBarState];
    [AIPreferences setNavigationBarColor: [Utils colorWithRGBHex: kHexFeedbackNavBarColor]
                       forViewController: self];
    [self downloadPhoto];
    [self presentData];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    if (self.isMovingFromParentViewController)
    {
        if (self.isItNewFeedback && !_isFeedbackSaved)
        {
            [self deletePhoto];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver: ACAccountStoreDidChangeNotification];
}

- (void) presentData
{
    NSString* nameVenue = @"";
    
    if (self.venue)
    {
        nameVenue = self.venue.name;
    }
    else if (self.venueName)
    {
        nameVenue = self.venueName;
    }
    NSString* companyName = [NSString stringWithFormat: @"%@?", nameVenue];
    
    NSDictionary* attribs = @{NSFontAttributeName: self.companyNameLabel.font};
    
    NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc] initWithString: companyName
                                                                                       attributes: attribs];
    NSRange redTextRange = NSMakeRange(0, companyName.length - 1);
    [attributedText setAttributes: @{NSFontAttributeName: [AIPreferences fontNormalWithSize: 15.0f]}
                            range: redTextRange];
    
    self.companyNameLabel.attributedText = attributedText;
    self.anonymousSwitch.on = (self.feedback.name.length > 0) ? NO : YES;
    self.anonymousLabel.text = [self.feedback userName];
    self.addPhotoImageView.isEditable = YES;
    self.addPhotoImageView.parentViewController = self;
    
    self.facebookButton.viewController = self;
    self.facebookButton.shareTexView = self.feedbackTextView;
    self.facebookButton.photoURL = self.feedback.photoURL;
    
    self.twitterButton.viewController = self;
    self.twitterButton.shareTexView = self.feedbackTextView;
    self.twitterButton.photoURL = self.feedback.photoURL;
    
    self.foursquareButton.viewController = self;
    self.foursquareButton.shareTexView = self.feedbackTextView;
    self.foursquareButton.photoURL = self.feedback.photoURL;
    if (self.venue)
    {
        self.foursquareButton.venueId = self.venue.venueId;
        self.foursquareButton.hidden = NO;
        self.foursquareLogoButton.hidden = NO;
    }
    else
    {
        self.foursquareButton.hidden = YES;
        self.foursquareLogoButton.hidden = YES;
    }
}

- (void) deletePhoto
{
    _needSavePhoto = YES;
    [self.feedback clearPhotoCache];
    [self setUpPhotoPreview];
    [self setUpOfButtonsState];
}

#pragma mark 

- (void) setUpOfNavigateButtons
{
    [self setLeftBarButtonItemType: BackButtonItem
                        action: @selector(backButtonPressed:)];
    
    _doneBarButton = [self setRightBarButtonItemType: DoneButtonItem
                                          action: @selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark -

- (IBAction) pressdOnRateButton: (UIButton*) aRateButton
{
    [self.rateView pressedOnStarNumber: aRateButton.tag];
}

- (void) downloadPhoto
{
    [self.feedback downloadPhotoWithResultBlock: ^(NSError* error)
     {
         if (error)
         {
             __weak AIFeedbackViewController* wself = self;
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error", nil)
                                                 text: [error localizedDescription]
                                        okButtonBlock: ^()
              {
                  __strong AIFeedbackViewController* sself = wself;
                  [sself showSignInViewController];
              }
                                    cancelButtonBlock: nil];
         }
         else
         {
             [self setUpPhotoPreview];
         }
     }
                                        view: self.view];
}

- (void) setUpPhotoPreview
{
    NSString* photoFullFileName = self.feedback.cachePhotoFullFileName;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: photoFullFileName])
    {
        UIImage* thumbImage = [UIImage imageWithContentsOfFile: photoFullFileName];
        self.addPhotoImageView.imageFileName = photoFullFileName;
        self.addPhotoImageView.image = thumbImage;
    }
    else
    {
        self.addPhotoImageView.image = [UIImage imageNamed: @"icon-photo.png"];
    }
}

- (NSString*) trimString: (NSString*) aString
{
    NSInteger i = 0;
    
    while ((i < [aString length]) && [[NSCharacterSet whitespaceCharacterSet] characterIsMember: [aString characterAtIndex: i]])
    {
        i++;
    }
    
    return [aString substringFromIndex: i];
}

- (IBAction) pressOnAddFeedbackButton: (id) sender
{
    NSString* thoughts = [self trimString: self.feedbackTextView.text];

    if (self.rateView.rate == 0)
    {
        [self.rateView shake];
        
        return;
    }
    
    if (thoughts.length == 0)
    {
        [self.feedbackTextView shake];
        
        return;
    }

    __block NSString* userid = @"";
    [[AIApplicationServer sharedInstance] getUserIdWithResultBlock: ^(NSString* aUserId){
        if (aUserId)
        {
            userid = aUserId;
        }
    }];
    
    if (self.isItNewFeedback)
    {
        self.feedback.userid = userid;
        self.feedback.venueid = self.venue.venueId;
        self.feedback.venuename = self.venue.name;
        self.feedback.categoryid = self.venue.categoryid;
        
        self.feedback.text = thoughts;
        self.feedback.rate = [NSNumber numberWithInteger: self.rateView.rate];
        
        if (self.anonymousSwitch.isOn)
        {
            self.feedback.name = @"";
            self.feedback.email = @"";
        }
        else
        {
            self.feedback.name = self.anonymousLabel.text;
            self.feedback.email = self.userEmail;
        }
        
        [self.feedback insertToDataBaseWithResultBlock: ^(NSError* aError)
         {
             if (aError)
             {
                 __weak AIFeedbackViewController* wself = self;
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"Error", nil)
                                                     text: [aError localizedDescription]
                                            okButtonBlock: ^()
                  {
                      __strong AIFeedbackViewController* sself = wself;
                      [sself showSignInViewController];
                  }
                                        cancelButtonBlock: nil];
             }
             else
             {
                 [self.feedbacks addObject: self.feedback];
                 [[AIChangeInLocalDataTrace sharedInstance] notifyAllObservers];
                 _isFeedbackSaved = YES;
                 [self backButtonPressed: nil];
             }
         }
                                               view: self.view];
    }
    else
    {
        self.feedback.text = thoughts;
        self.feedback.rate = [NSNumber numberWithInteger: self.rateView.rate];
        
        if (self.anonymousSwitch.isOn)
        {
            self.feedback.name = @"";
            self.feedback.email = @"";
        }
        else
        {
            self.feedback.name = self.anonymousLabel.text;
            self.feedback.email = self.userEmail;
        }
        [self.feedback updateDataWithNeedToSavePhoto: _needSavePhoto
                                     resultBlock: ^(NSError* aError)
         {
             if (aError)
             {
                 __weak AIFeedbackViewController* wself = self;
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"Error", nil)
                                                     text: [aError localizedDescription]
                                            okButtonBlock: ^()
                  {
                      __strong AIFeedbackViewController* sself = wself;
                      [sself showSignInViewController];
                  }
                                        cancelButtonBlock: nil];
             }
             else
             {
                 [[AIChangeInLocalDataTrace sharedInstance] notifyAllObservers];
                 _isFeedbackSaved = YES;
                 [self backButtonPressed: nil];
             }
         }];
    }
}

- (IBAction) editingHasFinished: (UITextField*) aTextField
{
    [aTextField resignFirstResponder];
}

- (IBAction) anonymousSwitchDidChanged: (UISwitch*) anAnonymousSwitch
{
    [self setUpAnonymousSwitch: anAnonymousSwitch.on];
}

- (void) setUpAnonymousSwitch: (BOOL) anAnonymousSwitchOn
{
    if (anAnonymousSwitchOn)
    {
        self.anonymousLabel.text = NSLocalizedString(@"Anonymous", nil);
    }
    else
    {
        AIUser* currentUser = [AIUser currentUser];

        if (currentUser)
        {
            self.userEmail = currentUser.email;
            self.anonymousLabel.text = [currentUser userName];
        }
        else
        {
            self.anonymousSwitch.on = YES;
            
            __weak AIFeedbackViewController* wself = self;
            [AIAlertView showAlertWythViewController: self
                                               title: NSLocalizedString(@"You should log in to the The Best Place.", nil)
                                                text:  NSLocalizedString(@"Want to do it now?", nil)
                                       okButtonBlock: ^()
             {
                 __strong AIFeedbackViewController* sself = wself;
                 [sself showSignInViewController];
             }
                                   cancelButtonBlock: ^()
             {
                 
             }];
        }
    }
}

#pragma mark Show Sign In Screen

- (void) showSignInViewController
{
    UIStoryboard* signInStoryboard = [UIStoryboard storyboardWithName: @"SignIn"
                                                               bundle: nil];
    UIViewController* loginViewController = [signInStoryboard instantiateViewControllerWithIdentifier: @"LoginVC"];
    
    [self.navigationController pushViewController: loginViewController
                                         animated: YES];
}

#pragma mark Photo

- (IBAction) showImagePickerForPhotoPicker: (id) sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: NSLocalizedString(@"Take a photo", nil), NSLocalizedString(@"Choose from Library", nil), nil];
    actionSheet.delegate = self;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tintColor = [UIColor blackColor];
    [actionSheet showInView: self.view];
}

- (void) willPresentActionSheet: (UIActionSheet*) actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock: ^(UIView* subview, NSUInteger idx, BOOL* stop)
    {
        if ([subview isKindOfClass: [UIButton class]])
        {
            UIButton* button = (UIButton*) subview;
            button.titleLabel.textColor = [Utils colorWithRGBHex: 0xFA6407];
        }
    }];
}

- (void) actionSheet: (UIActionSheet*) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            if (_photoMaker == nil)
            {
                _photoMaker = [[AIPhotoMakerController alloc] initWithViewController: self
                                                                            delegate: self];
            }
            
            [_photoMaker showImagePickerForCamera];
        }
            break;

        case 1:
        {
            if (_photoMaker == nil)
            {
                _photoMaker = [[AIPhotoMakerController alloc] initWithViewController: self
                                                                            delegate: self];
            }
            
            [_photoMaker showImagePickerForPhotoPicker];
        }
            break;
    }
}

- (IBAction) showImagePickerForCamera: (id) sender
{
    if (_photoMaker == nil)
    {
        _photoMaker = [[AIPhotoMakerController alloc] initWithViewController: self
                                                                    delegate: self];
    }
    
    [_photoMaker showImagePickerForCamera];
}

#pragma mark AISavePhotoDelegate protocol

- (void) savePhoto: (UIImage*) aPhotoImage
{
    if (aPhotoImage)
    {
        [MBProgressHUD startProgressWithAnimation: YES];
        
        [super savePhoto: aPhotoImage
              resultBlock: ^(NSError* error)
         {
             [MBProgressHUD stopProgressWithAnimation: YES];
             
             
             if (error)
             {
                 NSLog(@"%@", [error localizedDescription]);
             }
             else
             {
                 [self setUpPhotoPreview];
                 
                 _needSavePhoto = YES;
                 
             }
         }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self setUpOfButtonsState];
        });
    }
}

#pragma mark - Change State Showing

- (BOOL) isPhotoExist
{
    NSString* photoFullFileName = self.feedback.cachePhotoFullFileName;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: photoFullFileName])
    {
        return YES;
    }
    
    return NO;
}

- (void) setUpOfButtonsState
{
    NSString* textAddPhotoButton = nil;
    
    if ([self isPhotoExist])
    {
        textAddPhotoButton = NSLocalizedString(@"Change photo", nil);
    }
    else
    {
        textAddPhotoButton = NSLocalizedString(@"Add photo", nil);
    }
    
    [self.changeMenuPhotoButton setTitle: textAddPhotoButton
                                forState: UIControlStateNormal];
    
    NSString* textOnSaveButton = nil;
    
    textOnSaveButton = NSLocalizedString(@"Save Thoughts", nil);
    
    [self.addFeedbackButton setTitle: textOnSaveButton
                            forState: UIControlStateNormal];
}

- (void) sharingStatus
{
    if ([SLComposeViewController isAvailableForServiceType: SLServiceTypeFacebook])
    {
        self.twitterButton.enabled = YES;
        self.twitterButton.alpha = 1.0f;
    }
    else
    {
        self.twitterButton.enabled = NO;
        self.twitterButton.alpha = 0.5f;
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Button Press Handlers

- (void) doneButtonPressed: (id) sender
{
    [self.feedbackTextView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
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

@end
