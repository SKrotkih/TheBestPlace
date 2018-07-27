//
//  AIHomeViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIHomeViewController.h"
#import "AIAppDelegate.h"
#import "AIPreferences.h"
#import "AIUser.h"
#import "Utils.h"
#import "AIHomeScreenTableViewCell.h"
#import "MBProgressHUD.h"
#import "AIApplicationServer.h"
#import "AIFeedback.h"
#import "AIFeedbackShowViewController.h"
#import "AINetworkMonitor.h"
#import "FSVenue.h"
#import "AIChangeInLocalDataTrace.h"

static const CGFloat HeightOfTableCell = 62.0;
static const CGFloat kTimerIntervalForReloadingData = 30.0;

@interface AIHomeViewController () <UITableViewDataSource, UITabBarDelegate, AIChangeInLocalDataObserver>

@property (strong, nonatomic) AIFeedbackShowViewController* feedbackShowViewController;
@property (strong, nonatomic) UIRefreshControl* refreshControl;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *leaveFeedbackButton;
@property (weak, nonatomic) IBOutlet UIImageView *bgButtonImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) BOOL needReloadFeedData;

@end

@implementation AIHomeViewController
{
    NSMutableArray* _feedbacksFeed;
    NSMutableArray* _venues;
    NSTimer* _reloadDataTimer;
}

#pragma mark View life cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Home", nil);
    
    [self.leaveFeedbackButton setTitle: NSLocalizedString(@"Add Thoughts", nil)
                              forState: UIControlStateNormal];
    
    self.bgButtonImageView.layer.masksToBounds = YES;
    self.bgButtonImageView.layer.cornerRadius = 8.0f;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: self.refreshControl];
    [self.refreshControl addTarget: self
                            action: @selector(handleRefresh:)
                  forControlEvents: UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadData)
                                                 name: kSignInStateDidChangedNotification
                                               object: nil];
    
    _feedbacksFeed = [[NSMutableArray alloc] init];
    _venues = [[NSMutableArray alloc] init];
    
    [[AIChangeInLocalDataTrace sharedInstance] addObserver: self];
    
    self.needReloadFeedData = YES;
}

- (void) dealloc
{
    [[AIChangeInLocalDataTrace sharedInstance] removeObserver: self];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [AIPreferences setNavigationBarColor: [Utils colorWithRGBHex: kHexFeedbackNavBarColor]
                       forViewController: self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    _reloadDataTimer = [NSTimer scheduledTimerWithTimeInterval: kTimerIntervalForReloadingData
                                                        target: self
                                                      selector: @selector(reloadDataTimer:)
                                                      userInfo: nil
                                                       repeats: YES];
    
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    if (self.needReloadFeedData)
    {
        self.needReloadFeedData = NO;
        
        [self reloadData];
    }
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [_reloadDataTimer invalidate];
    _reloadDataTimer = nil;
}

- (void) reloadDataTimer: (NSTimer*) aTimer
{
    [self reloadData];
}

#pragma mark - AIChangeInLocalDataObserver

- (void) modelWasUpdated
{
    self.needReloadFeedData = YES;
}

#pragma mark -

- (void) reloadData
{
    [_feedbacksFeed removeAllObjects];
    [self.tableView reloadData];
    
    AIUser* currentUser = [AIUser currentUser];
    
    if (currentUser == nil)
    {
        return;
    }
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AIApplicationServer sharedInstance] fetrchFeedbacksFeedForUserID: currentUser.userid
                                                         friendsIdList: @""
                                                           resultBlock: ^(NSArray* aFeedbacks, NSArray* aVotes, NSError* error)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (error)
         {
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error while loading data", nil)
                                                 text: [error localizedDescription]];
             _feedbacksFeed = [[NSMutableArray alloc] init];
         }
         else
         {
             
             //         votes:
             //             date = 1401712141;
             //             firstname = Sergey;
             //             lastname = Krotkih;
             //             name = "Sergey Krotkih";
             //             venueid = 4e37f12662e1a8e9cc4a2cd8;
             //             vote = 0;
             //
             //         feedbacks
             //             date = 1399486619;
             //             feedbackid = 23;
             //             firstname = Sergey;
             //             lastname = Krotkih;
             //             name = "Sergey Krotkih";
             //             rate = 3;
             //             venueid = 52e02108498e92adf8b129de;
             
             NSMutableArray* feedbacksFeed = [[NSMutableArray alloc] initWithArray: aFeedbacks];
             
             for (NSDictionary* dict in aVotes)
             {
                 [feedbacksFeed addObject: dict];
             }
             
             _feedbacksFeed = [[feedbacksFeed sortedArrayUsingComparator: ^(id a, id b) {
                 NSDictionary* dict1 = (NSDictionary*) a;
                 NSDictionary* dict2 = (NSDictionary*) b;
                 double createdAt1 = [dict1[@"date"] doubleValue];
                 double createdAt2 = [dict2[@"date"] doubleValue];
                 
                 if (createdAt1 < createdAt2)
                 {
                     return (NSComparisonResult) NSOrderedDescending;
                 }
                 else if (createdAt1 > createdAt2)
                 {
                     return (NSComparisonResult) NSOrderedAscending;
                 }
                 else
                 {
                     return (NSComparisonResult) NSOrderedSame;
                 }
             }] mutableCopy];
             
             [self.tableView reloadData];
         }
     }];
}

#pragma mark UITableViewDataSource

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return _feedbacksFeed.count;
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return HeightOfTableCell;
}

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* cellIdentifier = @"cell";
    
    AIHomeScreenTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                      forIndexPath: indexPath];
    NSDictionary* dict = _feedbacksFeed[indexPath.row];
    
    cell.activity = dict;
    
    return cell;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    NSInteger row = indexPath.row;
    NSDictionary* dict = _feedbacksFeed[row];
    NSString* feedbackid = dict[@"feedbackid"];
    NSString* venueid = dict[@"venueid"];
    NSString* venueName = dict[@"venuename"];
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AIApplicationServer sharedInstance] fetchFeedbacksForVenueID: venueid
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
             for (AIFeedback* feedback in aFeedbacks)
             {
                 if ([feedback.feedbackid isEqualToString: feedbackid])
                 {
                     if (self.feedbackShowViewController == nil)
                     {
                         UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                                              bundle: nil];
                         AIFeedbackShowViewController* feedbackShowViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFeedbackShowVC"];
                         self.feedbackShowViewController = feedbackShowViewController;
                     }
                     self.feedbackShowViewController.feedback = feedback;
                     self.feedbackShowViewController.venue = nil;
                     self.feedbackShowViewController.venueName = venueName;
                     
                     for (FSVenue* venue in _venues)
                     {
                         if ([venue.venueId isEqualToString: venueid])
                         {
                             self.feedbackShowViewController.venue = venue;
                             
                             break;
                         }
                     }
                     
                     [self.navigationController pushViewController: self.feedbackShowViewController
                                                          animated: YES];
                     
                     break;
                 }
             }
         }
     }];
}

#pragma mark Refresh controlle handler

- (void) handleRefresh: (id) paramSender
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        [self.refreshControl endRefreshing];
        
        return;
    }
    
    [self.refreshControl endRefreshing];
    
    [self reloadData];
}

#pragma mark -

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [_feedbacksFeed removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction) mainMenuButtonPressed: (id)sender
{
    AIAppDelegate* appDelegate = [AIAppDelegate sharedDelegate];
    [appDelegate toggleLeftSideMenu];
}

#pragma mark Enable only Portrait mode

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
