//
//  AIFriendProfileViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFriendProfileViewController.h"
#import "AIHomeScreenTableViewCell.h"
#import "AIRateCompanyView.h"
#import "AIFriendsTableViewHeaderCell.h"
#import "AIFindFriendsTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AIFriendsFeedbacksTableViewController.h"
#import "AIFriendsFriendViewController.h"
#import "AIFeedbackShowViewController.h"
#import "FSVenue.h"
#import "AIFriendsViewController.h"
#import "AGMedallionView.h"
#import "AGMedallionView+DownloadImage.h"
#import "AIApplicationServer.h"
#import "MBProgressHUD.h"
#import "AINetworkMonitor.h"
#import "AIAppDelegate.h"
#import "UIViewController+NavButtons.h"

#import "AIFileManager.h"

@interface AIFriendProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIView* tableHeaderView;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (weak, nonatomic) IBOutlet AGMedallionView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profilePlaceLabel;

@property (weak, nonatomic) IBOutlet AIRateCompanyView* rateView;
@property (weak, nonatomic) IBOutlet UILabel* rate1Label;
@property (weak, nonatomic) IBOutlet UILabel* rate2Label;
@property (weak, nonatomic) IBOutlet UILabel* rate3Label;

@property (weak, nonatomic) IBOutlet UIButton *addToFriendButton;
@property (weak, nonatomic) IBOutlet UIView *addToFriendButtonView;

@property (nonatomic, strong) NSMutableArray* activity;
@property (strong, nonatomic) AIFeedbackShowViewController* feedbackShowViewController;

@end

@implementation AIFriendProfileViewController
{
    NSMutableArray* _venues;
    AIFriendsFeedbacksTableViewController* _friendsFeedbacksTableViewController;
    AIFriendsViewController* _friendsFriendViewController;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: self.refreshControl];
    [self.refreshControl addTarget: self
                            action: @selector(handleRefresh:)
                  forControlEvents: UIControlEventValueChanged];
    
    self.activity = [[NSMutableArray alloc] init];
    _venues = [[NSMutableArray alloc] init];
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self showUserProfile];

    [self showAllUserActivities];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark Content Show

- (void) showUserProfile
{
    self.title = self.user.name;
    NSString* imageUrl = self.user.photo_prefix;
    [self.profilePhotoView asyncDownloadImageURL: imageUrl
                           placeholderImageNamed: @"profile-icon"];
    self.profileNameLabel.text = [self.user userName];
    self.profilePlaceLabel.text = @"";
}

#pragma mark Import data from SUGAR

- (void) showAllUserActivities
{
    [[AIApplicationServer sharedInstance] saveNotesWithResultBlock: ^(NSData* aNotes, NSError *error)
    {
        if ([aNotes isKindOfClass: [NSDictionary class]])
        {
            NSDictionary* notes = (NSDictionary*) aNotes;

            NSArray* arrNotes = @[notes];
            
            NSError* error;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject: arrNotes
                                                               options: NSJSONWritingPrettyPrinted
                                                                 error: &error];
            [self saveData: jsonData
                toJsonFile: @"Opportunity.json"];
        }
        
    }];
}

- (void) saveData: (NSData*) aData
       toJsonFile: (NSString*) aJsonFileName
{
    NSString* temp = [[NSString alloc] initWithData: aData
                                           encoding: NSUTF8StringEncoding];
    
    NSString* json = [temp stringByReplacingOccurrencesOfString: @":null"
                                                     withString: @":\"\""];
    
    NSString* documentDir = [AIFileManager documentsPath];
    NSString* destFileName = [documentDir stringByAppendingPathComponent: aJsonFileName];
    
    NSError *error;
    BOOL succeed = [json writeToFile: destFileName
                          atomically: YES
                            encoding: NSUTF8StringEncoding
                               error: &error];
    if (succeed)
    {
        NSLog(@"Json data was saved successfully!");
    }
    else if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
}

#pragma mark -


- (void) showAllUserActivities2
{
    [self.activity removeAllObjects];
    [self.tableView reloadData];
    self.rate1Label.text = [NSString stringWithFormat: @"%i", 0];
    self.rate2Label.text = [NSString stringWithFormat: @"%i", 0];
    self.rate3Label.text = [NSString stringWithFormat: @"%i", 0];
    
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    NSString* userId = self.user.userid;
    
    // All feedbacks for User Id
    [[AIApplicationServer sharedInstance] fetrchFeedbacksFeedForUserID: @""
                                           friendsIdList: userId
                                                resultBlock: ^(NSArray* aFeedbacks, NSArray* aVotes, NSError* error)
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
                 NSDictionary* res = @{@"date": dict[@"date"],
                                       @"feedbackid": dict[@"feedbackid"],
                                       @"firstname": dict[@"firstname"],
                                       @"lastname": dict[@"lastname"],
                                       @"name": dict[@"name"],
                                       @"vote": dict[@"vote"],
                                       @"venueid": dict[@"venueid"],
                                       @"venuename": dict[@"venuename"]};
                 
                 [feedbacksFeed addObject: res];
             }
             
             NSArray* feedbacks = [feedbacksFeed sortedArrayUsingComparator: ^(id a, id b) {
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
             }];
             
             NSInteger rate1 = 0;
             NSInteger rate2 = 0;
             NSInteger rate3 = 0;
             
             for (NSDictionary* dict in feedbacks)
             {
                 NSString* vote = dict[@"vote"];
                 
                 if (vote.length == 0)
                 {
                     NSInteger rate = [dict[@"rate"] integerValue];
                     
                     switch (rate)
                     {
                         case 1:
                             rate1++;
                             break;
                         case 2:
                             rate2++;
                             break;
                         case 3:
                             rate3++;
                             break;
                             
                         default:
                             
                             break;
                     }
                 }
                 
                 [self.activity addObject: dict];
             }

             self.rate1Label.text = [NSString stringWithFormat: @"%ld", (long)rate1];
             self.rate2Label.text = [NSString stringWithFormat: @"%ld", (long)rate2];
             self.rate3Label.text = [NSString stringWithFormat: @"%ld", (long)rate3];
             
             [self.tableView reloadData];
         }
     }];
    
    [self.tableView reloadData];
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
    
    [self showAllUserActivities];
}

#pragma mark - Table view data source

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    NSInteger numberOfRows = 0;
    
    if (section == 0)
    {
        numberOfRows = 2;
    }
    else if (section == 1)
    {
        numberOfRows = self.activity.count;
    }
    
    return numberOfRows;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 2;
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger section = indexPath.section;
    NSInteger height = 0;
    
    if (section == 0)
    {
        height = 44.0f;
    }
    else
    {
        height = 60.0f;
    }
    
    return height;
}

- (CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection: (NSInteger) section
{
    NSInteger height = 0;
    
    if (section == 0)
    {
        height = 0;
    }
    else if (section == 1)
    {
        height = 33;
    }
    
    return height;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section
{
    if (section == 0)
    {
        UIView* header = [[UIView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 0.0f)];
        
        return header;
    }
    else if (section == 1)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem: 0
                                                     inSection: 0];
        AIFriendsTableViewHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier: @"sectionheader"
                                                                             forIndexPath: indexPath];
        cell.nameLabel.text = NSLocalizedString(@"RECENT ACTIVITY", nil);
        
        return cell;
    }

    return nil;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* cell0Identifier = @"cell0section";
    static NSString* cell1Identifier = @"cell1section";
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;

    if (section == 0)
    {
        AIFindFriendsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cell0Identifier
                                                                           forIndexPath: indexPath];

        if (row == 0)
        {
            cell.nameLabel.text = NSLocalizedString(@"Friends", nil);
            cell.iconImageView.image = [UIImage imageNamed: @"ic_friends"];
        }
        else
        {
            cell.nameLabel.text = NSLocalizedString(@"Feedbacks", nil);
            cell.iconImageView.image = [UIImage imageNamed: @"ic_feedbacks"];
        }
        
        return cell;
    }
    else if (section == 1)
    {
        AIHomeScreenTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cell1Identifier
                                                                          forIndexPath: indexPath];
        NSDictionary* dict = self.activity[indexPath.row];
        cell.activity = dict;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    [tableView deselectRowAtIndexPath: indexPath
                             animated: YES];
    
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    NSInteger row = indexPath.row;
    NSInteger secttion = indexPath.section;
    
    if (secttion == 0)
    {
        if (row == 0)
        {
            if (_friendsFriendViewController == nil)
            {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Friends"
                                                                     bundle: nil];
                 _friendsFriendViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFriendsFriendVC"];
                
            }
            _friendsFriendViewController.user = self.user;
            
            [self.navigationController pushViewController: _friendsFriendViewController
                                                 animated: YES];
        }
        else if (row == 1)
        {
            if (_friendsFeedbacksTableViewController == nil)
            {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Friends"
                                                                     bundle: nil];
                _friendsFeedbacksTableViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFriendsFeedbacksTVC"];
            }
            _friendsFeedbacksTableViewController.user = self.user;
            _friendsFeedbacksTableViewController.isItMyThoughts = NO;
            _friendsFeedbacksTableViewController.needReloadFeedData = YES;
            
            [self.navigationController pushViewController: _friendsFeedbacksTableViewController
                                                 animated: YES];
        }
    }
    else if (secttion == 1)  // activity
    {
        
        NSInteger row = indexPath.row;
        NSDictionary* dict = self.activity[row];
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
                         self.feedbackShowViewController.venueName = venueName;                         
                         self.feedbackShowViewController.venue = nil;
                         
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
}

#pragma mark 

- (IBAction) addToFriendsButtonPressed: (id) sender
{

    
}

#pragma mark Enable only Portrait mode

- (BOOL) shouldAutorotate
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
