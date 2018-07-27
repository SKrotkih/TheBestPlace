//
//  AIFeedbackShowViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFeedbackShowViewController.h"
#import "AIRateCompanyView.h"
#import "AIFileManager.h"
#import "AIFeedbackPhotoImageView.h"
#import "AIFeedbackViewController.h"
#import "AIApplicationServer.h"
#import "UIDevice+IdentifierAddition.h"
#import "AIVote.h"
#import "AIApplicationServer.h"
#import "AIChangeInLocalDataTrace.h"
#import "UIViewController+NavButtons.h"

@interface AIFeedbackShowViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel* wahatAreYouThoughtLabel;
@property (weak, nonatomic) IBOutlet UILabel* companyNameLabel;
@property (weak, nonatomic) IBOutlet UITextView* feedbackTextField;
@property (weak, nonatomic) IBOutlet AIRateCompanyView* rateView;
@property (weak, nonatomic) IBOutlet AIFeedbackPhotoImageView* photoImageView;

@property (weak, nonatomic) IBOutlet UIImageView* buttonBgImageView;

@property (weak, nonatomic) IBOutlet UIButton* rateSmile1;
@property (weak, nonatomic) IBOutlet UIButton* rateSmile2;
@property (weak, nonatomic) IBOutlet UIButton* rateSmile3;

@property (weak, nonatomic) IBOutlet UIView *deleteThoughtsButtonBgView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIButton *deleteThoughtsButton;
@property (strong, nonatomic) AIFeedbackViewController* addFeedbackViewController;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint* buttonYOffsetConstraint;

@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dislikeCountLabel;

@end

@implementation AIFeedbackShowViewController
{
    UIBarButtonItem* _editBarButton;
}

#pragma mark - UIView life cycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"View Thoughts", nil);
    
    [self setLeftBarButtonItemType: BackButtonItem
                        action: @selector(backButtonPressed:)];
    
    [self.deleteThoughtsButton setTitle: NSLocalizedString(@"Delete Thoughts", nil)
                               forState: UIControlStateNormal];
    self.wahatAreYouThoughtLabel.text = NSLocalizedString(@"Your thoughts about", nil);
    
    self.rateView.rateSmile1 = self.rateSmile1;
    self.rateView.rateSmile2 = self.rateSmile2;
    self.rateView.rateSmile3 = self.rateSmile3;

    self.photoImageView.parentViewController = self;
    self.photoImageView.isEditable = NO;

    _editBarButton = [self setRightBarButtonItemType: EditButtonItem
                                              action: @selector(editButtonPressed:)];
}

- (void) viewWillAppear: (BOOL) animated
{
    [self presentThoughtsData];
}

- (void) presentThoughtsData
{
    [self downloadPhoto];

    self.feedbackTextField.text = self.feedback.text;
    self.rateView.rate = [self.feedback.rate integerValue];
    self.feedbackTextField.editable = NO;
    
    NSString* nameVenue = @"";
    
    if (self.venue)
    {
        nameVenue = self.venue.name;
    }
    else if (self.venueName)
    {
        nameVenue = self.venueName;
    }
    
    NSString* companyName = [NSString stringWithFormat: @"%@:", nameVenue];
    
    NSDictionary* attribs = @{NSFontAttributeName: self.companyNameLabel.font};
    NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc] initWithString: companyName
                                                                                       attributes: attribs];
    NSRange redTextRange = NSMakeRange(0, companyName.length - 1);
    [attributedText setAttributes: @{NSFontAttributeName: [AIPreferences fontNormalWithSize: 15.0f]}
                            range: redTextRange];
    self.companyNameLabel.attributedText = attributedText;
    
    [self.feedback isItMyFeedbackWithResultBlock: ^(BOOL isItMyFeedback){
        NSString* text = nil;
        CGFloat height = CGRectGetHeight(self.view.frame);
        
        if (isItMyFeedback)
        {
            text = NSLocalizedString(@"Your thoughts about", nil);
            [self.deleteThoughtsButton setTitle: NSLocalizedString(@"Delete Thoughts", nil)
                                       forState: UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = _editBarButton;
            self.buttonYOffsetConstraint.constant = height - 48.0f;
            [self.view bringSubviewToFront: self.deleteThoughtsButtonBgView];
        }
        else
        {
            text = [NSString stringWithFormat: NSLocalizedString(@"%@'s thoughts about", nil), self.feedback.name];
            self.navigationItem.rightBarButtonItem = nil;
            self.buttonYOffsetConstraint.constant = height;
        }
        
        self.wahatAreYouThoughtLabel.text = text;
    }
                                checkDeviceId: NO
     ];
    
    [self likeCountResolve];
}

#pragma mark - Pucture working

- (void) downloadPhoto
{
    [self.feedback downloadPhotoWithResultBlock: ^(NSError* error)
     {
         if (error)
         {
             __weak AIFeedbackShowViewController *wself = self;
             
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error", nil)
                                                 text: [error localizedDescription]
                                        okButtonBlock: ^()
             {
                 __strong AIFeedbackShowViewController*sself = wself;
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
        self.photoImageView.imageFileName = photoFullFileName;
        self.photoImageView.image = thumbImage;
    }
    else
    {
        self.photoImageView.image = nil;   //[UIImage imageNamed: @"icon-photo.png"];
    }
}

#pragma mark IBActions

- (IBAction) editButtonPressed: (id) sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                         bundle: nil];
    AIFeedbackViewController* feedbackViewController = [storyboard instantiateViewControllerWithIdentifier: @"FeedbackVC"];
    self.addFeedbackViewController = feedbackViewController;
    self.addFeedbackViewController.venue = self.venue;
    self.addFeedbackViewController.venueName = self.venueName;
    self.addFeedbackViewController.feedback = self.feedback;
    self.addFeedbackViewController.feedbacks = nil;
    self.addFeedbackViewController.isItNewFeedback = NO;
    [self.navigationController pushViewController: self.addFeedbackViewController
                                         animated: YES];
}

- (IBAction) deleteThoughtsButtonPressed: (id) sender
{
    [self.feedback removeFeedbackWithResultBlock: ^(NSError* error)
     {
         if (error)
         {
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error", nil)
                                                 text: [error localizedDescription]];
         }
         else
         {
             [[AIChangeInLocalDataTrace sharedInstance] notifyAllObservers];
             [self.navigationController popViewControllerAnimated: YES];
         }
     }
                                         view: self.view];
}

#pragma mark Like - Dislike

- (IBAction) likeButtonPressed: (id)sender
{
    [self setUpLike: YES];
}

- (IBAction) dislikeButtonPressed:(id)sender
{
    [self setUpLike: NO];
}

- (void) setUpLike: (BOOL) isLiked
{
    AIUser* currentUser = [AIUser currentUser];
    
    if (currentUser)
    {
        AIVote* vote = [[AIVote alloc] initWithFeedback: self.feedback];
        vote.userid = currentUser.userid;
        vote.like = [NSString stringWithFormat: @"%i", isLiked ? 1 : 0];
        
        [[AIApplicationServer sharedInstance] addVote: vote
                                     resultBlock: ^(NSError *error)
         {
             if (error)
             {
                 NSLog(@"%@", [error localizedDescription]);
             }
             else if (isLiked)
             {
                 self.likeCountLabel.text = [NSString stringWithFormat: @"%ld", (long)([self.likeCountLabel.text integerValue] + 1)];
             }
             else if (!isLiked)
             {
                 self.dislikeCountLabel.text = [NSString stringWithFormat: @"%ld", (long)([self.dislikeCountLabel.text integerValue] + 1)];
             }
         }];
    }
    else
    {
        __weak AIFeedbackShowViewController* wself = self;
        [AIAlertView showAlertWythViewController: self
                                           title: NSLocalizedString(@"You should log in to the The Best Place.", nil)
                                            text:  NSLocalizedString(@"Want to do it now?", nil)
                                   okButtonBlock: ^()
         {
             __strong AIFeedbackShowViewController* sself = wself;
             [sself showSignInViewController];
         }
                               cancelButtonBlock: ^()
         {
             
         }];
    }
}

- (void) likeCountResolve
{
    self.likeCountLabel.text = @"0";
    self.dislikeCountLabel.text = @"0";
    
    AIVote* vote = [[AIVote alloc] initWithFeedback: self.feedback];
    
    [[AIApplicationServer sharedInstance] fetchVote: vote
                                    resultBlock: ^(NSDictionary* votes, NSError *error)
     {
         if (error)
         {
             NSLog(@"%@", [error localizedDescription]);
         }
         else
         {
             self.likeCountLabel.text = [NSString stringWithFormat: @"%li", (long)[votes[@"like"] integerValue]];
             self.dislikeCountLabel.text = [NSString stringWithFormat: @"%li", (long)[votes[@"dislike"] integerValue]];
         }
     }];
}

#pragma mark - Sign In Will Be Shown

- (void) showSignInViewController
{
    UIStoryboard* signInStoryboard = [UIStoryboard storyboardWithName: NSLocalizedString(@"SignIn", nil)
                                                               bundle: nil];
    UIViewController* loginViewController = [signInStoryboard instantiateViewControllerWithIdentifier: @"LoginVC"];
    
    [self.navigationController pushViewController: loginViewController
                                         animated: YES];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark -

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotations

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    
}

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return YES;
}

@end
