//
//  AICompanyProfileViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/28/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AICompanyProfileViewController.h"
#import "AIRateCompanyView.h"
#import "AIFeedbackViewController.h"
#import "AIFeedbackShowViewController.h"
#import "AICompanyProfileTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AIApplicationServer.h"
#import "MBProgressHUD.h"
#import "AINetworkMonitor.h"
#import "AILikedFeedbacksTableViewController.h"
#import "AIUser.h"
#import "UIViewController+NavButtons.h"
#import "AIChangeInLocalDataTrace.h"

@interface AICompanyProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, AIChangeInLocalDataObserver>
@property (weak, nonatomic) IBOutlet UIImageView* placeCategoryImageView;
@property (nonatomic, copy) NSString* placeCategoryImageUrl;
@property (nonatomic, copy) NSString* companyImageUrl;

@property (weak, nonatomic) IBOutlet UILabel* venueNameLabel;

@property (weak, nonatomic) IBOutlet UIButton* addFeedbackButton;
@property (weak, nonatomic) IBOutlet UIImageView* buttonBgImageView;

@property (weak, nonatomic) IBOutlet UIView* tableHeaderView;
@property (weak, nonatomic) IBOutlet UITableView* feedbacksTableView;

@property (weak, nonatomic) IBOutlet UILabel* addressTextLabel;
@property (weak, nonatomic) IBOutlet UILabel* addressLabel;
@property (weak, nonatomic) IBOutlet UILabel* distanceLabel;

@property (weak, nonatomic) IBOutlet UILabel* thoughtsTextLabel;

@property (weak, nonatomic) IBOutlet AIRateCompanyView* rateView;
@property (weak, nonatomic) IBOutlet UILabel* rate1Label;
@property (weak, nonatomic) IBOutlet UILabel* rate2Label;
@property (weak, nonatomic) IBOutlet UILabel* rate3Label;

@property (strong, nonatomic) NSMutableArray* feedbacks;
@property (strong, nonatomic) NSMutableArray* likeFeedbacks;
@property (strong, nonatomic) NSMutableArray* disLikeFeedbacks;
@property (strong, nonatomic) NSMutableArray* likeUsers;
@property (strong, nonatomic) NSMutableArray* disLikeUsers;

@property (strong, nonatomic) AIFeedbackViewController* addFeedbackViewController;
@property (strong, nonatomic) AIFeedbackShowViewController* feedbackShowViewController;
@property (strong, nonatomic) AILikedFeedbacksTableViewController* likedFeedbacksViewController;

@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, assign) BOOL needReloadFeedData;

@end

@implementation AICompanyProfileViewController

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        // Custom initialization
    }

    return self;
}

#pragma mark UIView life cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self.venue name];
    
    self.feedbacksTableView.tableHeaderView = self.tableHeaderView;
    
    self.likeFeedbacks = [[NSMutableArray alloc] init];
    self.disLikeFeedbacks = [[NSMutableArray alloc] init];
    self.likeUsers = [[NSMutableArray alloc] init];
    self.disLikeUsers = [[NSMutableArray alloc] init];

    [self setUpNavigationButtons];
    
    self.venueNameLabel.text = self.venue.name;
    
    if (self.venue.location.address)
    {
        self.addressTextLabel.text = NSLocalizedString(@"Address:", @"Address:");
        self.addressLabel.text = [NSString stringWithFormat: @"%@", self.venue.location.address];
    }
    else
    {
        self.addressTextLabel.text = @"";
        self.addressLabel.text = @"";
    }

    [self.addFeedbackButton setTitle: NSLocalizedString(@"Add Thoughts", nil)
                            forState: UIControlStateNormal];
    
    self.distanceLabel.text = [NSString stringWithFormat: @"%@ m", self.venue.location.distance];
    
    NSString* imageUrl = [NSString stringWithFormat: @"%@32%@", self.venue.imageUrlprefix, self.venue.imageUrlsuffix];
    self.placeCategoryImageUrl = imageUrl;
    
    NSString* companyImageUrl = [NSString stringWithFormat: @"%@64%@", self.venue.imageUrlprefix, self.venue.imageUrlsuffix];
    self.companyImageUrl = companyImageUrl;
    
    self.thoughtsTextLabel.text = NSLocalizedString(@"THOUGHTS", nil);

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.feedbacksTableView addSubview: self.refreshControl];
    [self.refreshControl addTarget: self
                            action: @selector(handleRefresh:)
                  forControlEvents: UIControlEventValueChanged];
    
    [[AIChangeInLocalDataTrace sharedInstance] addObserver: self];
    
    self.needReloadFeedData = YES;
}

- (void) setUpNavigationButtons
{
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
    
    [self setRightBarButtonItemType: AddButtonItem
                         action: @selector(addFeedbackButtonPressed:)];
}

- (void) dealloc
{
    [[AIChangeInLocalDataTrace sharedInstance] removeObserver: self];
}

- (void) viewWillAppear: (BOOL) animated
{
    if (self.needReloadFeedData)
    {
        self.needReloadFeedData = NO;
        [self reloadData];
    }
}

#pragma mark -

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void) reloadData
{
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AIApplicationServer sharedInstance] fetchFeedbacksForVenueID: self.venue.venueId
                                                resultBlock: ^(NSArray* aFeedbacks, NSArray* aLikes, NSArray* aDisLikes, NSArray* aLikeUsers, NSArray* aDisLikeUsers, NSError* error)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (error)
         {
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error while loading data", nil)
                                                 text: [error localizedDescription]];
         }
         else
         {
             self.feedbacks = [[aFeedbacks sortedArrayUsingComparator: ^NSComparisonResult(id a, id b){
                 AIFeedback* feedback1 = (AIFeedback*)a;
                 AIFeedback* feedback2 = (AIFeedback*)b;
                 double first = [feedback1.createdAt doubleValue];
                 double second = [feedback2.createdAt doubleValue];
                 
                 return first > second;
             }] mutableCopy];
             
             [self.likeFeedbacks removeAllObjects];
             [self.disLikeFeedbacks removeAllObjects];
             [self.likeUsers removeAllObjects];
             [self.disLikeUsers removeAllObjects];
             
             for (NSDictionary* dict in aLikes)
             {
                 [self.likeFeedbacks addObject: dict];
             }
             
             for (NSDictionary* dict in aDisLikes)
             {
                 [self.disLikeFeedbacks addObject: dict];
             }

             for (NSDictionary* dict in aLikeUsers)
             {
                 [self.likeUsers addObject: dict];
             }

             for (NSDictionary* dict in aDisLikeUsers)
             {
                 [self.disLikeUsers addObject: dict];
             }
             
             [self.feedbacksTableView reloadData];
             
             [self recalcRate];
         }
     }];
}

- (void) recalcRate
{
    self.rate1Label.text = @"0";
    self.rate2Label.text = @"0";
    self.rate3Label.text = @"0";

    for (AIFeedback* feedback in self.feedbacks)
    {
        switch ([feedback.rate integerValue])
        {
            case 0:
                
                break;
                
            case 1:
            {
                long r = [self.rate1Label.text integerValue];
                self.rate1Label.text = [NSString stringWithFormat: @"%ld", r + 1];
            }
                break;
                
            case 2:
            {
                long r = [self.rate2Label.text integerValue];
                self.rate2Label.text = [NSString stringWithFormat: @"%ld", r + 1];
            }
                break;
                
            case 3:
            {
                long r = [self.rate3Label.text integerValue];
                self.rate3Label.text = [NSString stringWithFormat: @"%ld", r + 1];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void) prepareForSegue: (UIStoryboardSegue*) segue
                  sender: (id) sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark UITableViewDelegate

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.feedbacks.count;
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return 115.0f;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* reuseIndetifier = @"companyProfileTableViewCell";
    AICompanyProfileTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: reuseIndetifier
                                                                          forIndexPath: indexPath];
    NSInteger row = indexPath.row;
    AIFeedback* feedback = self.feedbacks[row];
    
    cell.myToughtsTextView.text = feedback.text;
    cell.dateLabel.text = [feedback stringOfDateCreatedAt];
    cell.rateImageView.image = [UIImage imageNamed: [NSString stringWithFormat: @"rate%li_select.png", (long)[feedback.rate integerValue]]];
    cell.userNameLabel.text = [feedback userName];
    cell.delegate = self;
    cell.tag = row;

    NSInteger likeCounter = 0;

    for (NSDictionary* dict in self.likeFeedbacks)
    {
        NSString* currFeedbackid = dict[@"feedbackid"];

        if ([currFeedbackid isEqual: feedback.feedbackid])
        {
            likeCounter += [dict[@"likeCount"] integerValue];
        }
    }

    NSInteger disLikeCounter = 0;
    
    for (NSDictionary* dict in self.disLikeFeedbacks)
    {
        NSString* currFeedbackid = dict[@"feedbackid"];
        
        if ([currFeedbackid isEqual: feedback.feedbackid])
        {
            disLikeCounter += [dict[@"dislikeCount"] integerValue];
        }
    }
    cell.likeCounterLabel.text = [NSString stringWithFormat: @"%li", (long)likeCounter];
    cell.dislikeCounterLabel.text = [NSString stringWithFormat: @"%li", (long)disLikeCounter];

    NSString* userId = feedback.userid;
    BOOL isItMyFriend = NO;
    
    for (AIUser* friend in self.allMyFiends)
    {
        if ([friend.userid isEqualToString: userId])
        {
            isItMyFriend = YES;

            break;
        }
    }
    
    cell.myFriendImageView.hidden = !isItMyFriend;
    
    return cell;
}

- (void) tableView: (UITableView*) tableView
commitEditingStyle: (UITableViewCellEditingStyle) editingStyle
 forRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger row = indexPath.row;
    
    if (row < self.feedbacks.count)
    {
        AIFeedback* feedback = self.feedbacks[row];
        [feedback removeFeedbackWithResultBlock: ^(NSError* error)
         {
             if (error)
             {
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"Error", nil)
                                                     text: [error localizedDescription]];
             }
             else
             {
                 [self reloadData];
             }
         }
                                        view: self.view];
    }
}

- (UITableViewCellEditingStyle) tableView: (UITableView*) tableView editingStyleForRowAtIndexPath: (NSIndexPath*) indexPath
{
    __block UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;
    
    NSUInteger row = [indexPath row];
    
    if (row < self.feedbacks.count)
    {
        AIFeedback* feedback = self.feedbacks[row];
        
        [feedback isItMyFeedbackWithResultBlock: ^(BOOL isItMyFeedback){
            editingStyle = UITableViewCellEditingStyleDelete;
        }
                               checkDeviceId: YES
         ];
    }

    return editingStyle;
}

- (void) tableView: (UITableView*) tableView didEndEditingRowAtIndexPath: (NSIndexPath*) indexPath
{
    [self reloadData];
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    [tableView deselectRowAtIndexPath: indexPath
                             animated: YES];
    
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    if (self.feedbackShowViewController == nil)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                             bundle: nil];
        AIFeedbackShowViewController* feedbackShowViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFeedbackShowVC"];
        self.feedbackShowViewController = feedbackShowViewController;
    }
    NSInteger row = indexPath.row;
    AIFeedback* feedback = self.feedbacks[row];
    self.feedbackShowViewController.feedback = feedback;
    self.feedbackShowViewController.venue = self.venue;
    [self.navigationController pushViewController: self.feedbackShowViewController
                                         animated: YES];
}

#pragma mark -

- (void) setCompanyImageUrl: (NSString*) imageUrl
{
    if (!imageUrl || [_companyImageUrl isEqualToString: imageUrl])
    {
        return;
    }

    _companyImageUrl = nil;
    _companyImageUrl = [imageUrl copy];

//    [self setUpImageView: self.companyImageView
//                 withUrl: _companyImageUrl];
}

- (void) setPlaceCategoryImageUrl: (NSString*) imageUrl
{
    if (!imageUrl || [_placeCategoryImageUrl isEqualToString: imageUrl])
    {
        return;
    }

    _placeCategoryImageUrl = nil;
    _placeCategoryImageUrl = [imageUrl copy];

    [self setUpImageView: self.placeCategoryImageView
                 withUrl: _placeCategoryImageUrl];
}

- (void) setUpImageView: (UIImageView*) anImageView
                withUrl: (NSString*) imageUrl
{
    anImageView.layer.masksToBounds = YES;
    anImageView.layer.cornerRadius = 8.0f;
    
    NSURL* urlRequest = [NSURL URLWithString: imageUrl];
    
    self.venue.categoryImage = [UIImage imageNamed: @"empty_square"];
    [anImageView setImageWithURLRequest: [NSURLRequest requestWithURL: urlRequest]
                       placeholderImage: nil
                                success: ^(NSURLRequest* request , NSHTTPURLResponse* response , UIImage* image)
     {
         self.venue.categoryImage = image;
     }
                                failure: ^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error)
     {
         NSLog(@"Error while loading of an Image from server: %@", error);
     }
     ];
}

#pragma mark AIChangeInLocalDataObserver protocol

- (void) modelWasUpdated
{
    self.needReloadFeedData = YES;
}

#pragma mark Add Feedback button pressed

- (IBAction) addFeedbackButtonPressed: (id)sender
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                         bundle: nil];
    AIFeedbackViewController* feedbackViewController = [storyboard instantiateViewControllerWithIdentifier: @"FeedbackVC"];
    self.addFeedbackViewController = feedbackViewController;
    self.addFeedbackViewController.venue = self.venue;
    self.addFeedbackViewController.feedback = [[AIFeedback alloc] init];
    self.addFeedbackViewController.feedbacks = self.feedbacks;
    self.addFeedbackViewController.isItNewFeedback = YES;
    [self.navigationController pushViewController: self.addFeedbackViewController
                                         animated: YES];
}

#pragma mark Refresh controlle handler

- (void) handleRefresh: (id) paramSender
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        [self.refreshControl endRefreshing];
        
        return;
    }
    
    /* Put a bit of delay between when the refresh control is released
     and when we actually do the refreshing to make the UI look a bit
     smoother than just doing the update without the animation */
    int64_t delayInSeconds = 1.0f;
    dispatch_time_t popTime =
    dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.refreshControl endRefreshing];
        [self reloadData];
    });
}

#pragma mark PressOnLikeDislikeDelegate protocol

- (void) likeButtonPressed: (AICompanyProfileTableViewCell*) aCell
{
    [self friendsLickedShowViewControllerForFeedbackRow: aCell.tag
                                             dataSource: self.likeUsers
                                                  liked: YES];
}

- (void) disLikeButtonPressed: (AICompanyProfileTableViewCell*) aCell
{
    [self friendsLickedShowViewControllerForFeedbackRow: aCell.tag
                                             dataSource: self.disLikeUsers
                                                  liked: NO];
}

- (void) friendsLickedShowViewControllerForFeedbackRow: (NSInteger) aRowFeedback
                                            dataSource: (NSArray*) aDataSource
                                                 liked: (BOOL) anIsLiked
{
    if (self.likedFeedbacksViewController == nil)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                             bundle: nil];
        AILikedFeedbacksTableViewController* likedFeedbacksTVC = [storyboard instantiateViewControllerWithIdentifier: @"LikedFeedbacksTVC"];
        self.likedFeedbacksViewController = likedFeedbacksTVC;
    }
    AIFeedback* feedback = self.feedbacks[aRowFeedback];
    self.likedFeedbacksViewController.feedback = feedback;
    self.likedFeedbacksViewController.isLiked = anIsLiked;
    self.likedFeedbacksViewController.dataSource = aDataSource;
    
    [self.navigationController pushViewController: self.likedFeedbacksViewController
                                         animated: YES];
}

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark Enable only Portrait mode

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

@end
