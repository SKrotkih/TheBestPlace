//
//  AIFriendsFeedbacksTableViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/6/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFriendsFeedbacksTableViewController.h"
#import "AIFriendsFeedbacksTableViewCell.h"
#import "AIAppDelegate.h"
#import "MBProgressHUD.h"
#import "AINetworkMonitor.h"
#import "AIApplicationServer.h"
#import "AIFeedbackShowViewController.h"
#import "MultiSelectSegmentedControl.h"
#import "AICategoriesTableViewController.h"
#import "AIChangeInLocalDataTrace.h"
#import "UIViewController+NavButtons.h"

@interface AIFriendsFeedbacksTableViewController () <MultiSelectSegmentedControlDelegate, AICategoriViewControllerDelegate, AIChangeInLocalDataObserver>
@property (strong, nonatomic) AIFeedbackShowViewController* feedbackShowViewController;
@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl* segmentedControl;
@property (strong, nonatomic) NSArray* selectedCategoryIds;
@property (strong, nonatomic) NSMutableArray* categories;
@property (nonatomic, assign) BOOL allCategories;

@property (nonatomic, strong) NSMutableArray* feedbacks;
@property (nonatomic, strong) NSMutableArray* votes;

@end

@implementation AIFriendsFeedbacksTableViewController
{
    NSMutableArray* _feedbacksDataSource;
    NSMutableArray* _moodState;
    BOOL _isShowCategoryView;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    NSString* title = nil;
    
    if (self.isItMyThoughts)
    {
        title = NSLocalizedString(@"My Thoughts", nil);
        [self setLeftBarButtonItemType: MenuButtonItem
                            action: @selector(mainMenuButtonPressed:)];
    }
    else
    {
        title = NSLocalizedString(@"Friends Feedbacks", nil);
        [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
    }
    self.title = title;
    
    [self setRightBarButtonItemType: CategoryButtonItem
                         action: @selector(categoryButtonPressed:)];

    _feedbacks = [[NSMutableArray alloc] init];
    _votes = [[NSMutableArray alloc] init];
    _feedbacksDataSource = [[NSMutableArray alloc] init];
    
    _categories = [[NSMutableArray alloc] init];
    _allCategories = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: self.refreshControl];
    [self.refreshControl addTarget: self
                            action: @selector(handleRefresh:)
                  forControlEvents: UIControlEventValueChanged];

    [self.segmentedControl setTitle: NSLocalizedString(@"Positive", nil)
                  forSegmentAtIndex: 0];

    [self.segmentedControl setTitle: NSLocalizedString(@"Neutral", nil)
                  forSegmentAtIndex: 1];

    [self.segmentedControl setTitle: NSLocalizedString(@"Negative", nil)
                  forSegmentAtIndex: 2];
    
    self.segmentedControl.delegate = self;
    

    _moodState = [[NSMutableArray alloc] initWithCapacity: 3];

    [self.segmentedControl selectAllSegments: YES];
    
    for (int i = 0; i < 3; i++)
    {
        _moodState[i] = [NSNumber numberWithBool: YES];
    }
    
    [[AIChangeInLocalDataTrace sharedInstance] addObserver: self];
    
    self.needReloadFeedData = YES;
}

- (void) dealloc
{
    [[AIChangeInLocalDataTrace sharedInstance] removeObserver: self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];

    if (self.needReloadFeedData)
    {
        self.needReloadFeedData = NO;
        [self selectFeedbacks];
    }
}

#pragma mark - AIChangeInLocalDataObserver protocol

- (void) modelWasUpdated
{
    self.needReloadFeedData = YES;
}

#pragma mark - Data source generate

- (void) handleRefresh: (id) paramSender
{
    [self.refreshControl endRefreshing];
    
    [self selectFeedbacks];
}

- (void) selectFeedbacks
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    [self.feedbacks removeAllObjects];
    [self.votes  removeAllObjects];
    
    [_feedbacksDataSource removeAllObjects];
    
    [self.tableView reloadData];
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    NSString* userId = self.user.userid;
    
    [[AIApplicationServer sharedInstance] fetrchFeedbacksFeedForUserID: @""
                                           friendsIdList: userId   // All feedbacks
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
             //             categoryid = 4e37f12662e1a8e9cc4a2cd8;
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
             //             categoryid = 4e37f12662e1a8e9cc4a2cd8;
             
             for (NSDictionary* dict in aVotes)
             {
                 NSDictionary* res = @{@"feedbackid": dict[@"feedbackid"],
                                       @"vote": dict[@"vote"]};
                 
                 [self.votes addObject: res];
             }
             
             NSMutableArray* feedbacksFeed = [[NSMutableArray alloc] initWithArray: aFeedbacks];
             
             NSArray* tempArray = [feedbacksFeed sortedArrayUsingComparator: ^(id a, id b) {
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
             
             for (NSDictionary* dict in tempArray)
             {
                 [self.feedbacks addObject: dict];
             }
             
             [self refreshThoughts];
         }
     }];
}


- (void) refreshThoughts
{
    [_feedbacksDataSource removeAllObjects];
    
    for (NSDictionary* dict in self.feedbacks)
    {
        NSInteger rate = [dict[@"rate"] integerValue];
        NSString* categoryid = dict[@"categoryid"];
        NSInteger index = 0;
        
        switch (rate)
        {
            case 1:
                index = 2;
                break;
                
            case 2:
                index = 1;
                break;
                
            case 3:
                index = 0;
                break;
                
            default:
                break;
        }
        
        BOOL enable = [_moodState[index] boolValue];
        
        if (enable)
        {
            if (self.allCategories)
            {
                [_feedbacksDataSource addObject: dict];
            }
            else if (self.selectedCategoryIds)
            {
                for (NSString* currCategoryId in self.selectedCategoryIds)
                {
                    if ([currCategoryId isEqualToString: categoryid])
                    {
                        [_feedbacksDataSource addObject: dict];
                        
                        break;
                    }
                }
            }
        }
    }
    [self.tableView reloadData];
}



- (void) multiSelect: (MultiSelectSegmentedControl*) multiSelecSegmendedControl
      didChangeValue: (BOOL) value
             atIndex: (NSUInteger) index
{
    _moodState[index] = [NSNumber numberWithBool: value];
    [self refreshThoughts];
}

#pragma mark Category filter

- (void) categoryButtonPressed: (id) sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                         bundle: nil];
    AICategoriesTableViewController* categoriesTVC = [storyboard instantiateViewControllerWithIdentifier: @"AICategoriesTVC"];
    categoriesTVC.needShowAllCategories = YES;
    categoriesTVC.delegate = self;
    categoriesTVC.allCategories = self.allCategories;
    categoriesTVC.categories = self.categories;
    [self.navigationController pushViewController: categoriesTVC
                                         animated: YES];
}

#pragma mark AICategoriViewControllerDelegate

- (void) selectCategory: (NSDictionary*) aCategoryDict
{
    NSAssert(NO, @"You should not call this method dekefate!");
}

- (void) selectedCategories: (NSArray*) aSelectedCategoriesArray
              allCategories: (BOOL) anAllCategories;
{
    self.selectedCategoryIds = aSelectedCategoriesArray;
    self.allCategories = anAllCategories;
    
    [self refreshThoughts];
}

#pragma mark - Table view data source

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return _feedbacksDataSource.count;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return 96.0f;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* cellIdentifier = @"cell";
    AIFriendsFeedbacksTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                            forIndexPath: indexPath];
    
    NSInteger row =  indexPath.row;
    NSDictionary* dict = _feedbacksDataSource[row];

    NSInteger rate = [dict[@"rate"] integerValue];
    NSString* imgName = nil;
    
    switch (rate)
    {
        case 1:
            imgName = @"rate1_select";
            break;
        case 2:
            imgName = @"rate2_select";
            break;
        case 3:
            imgName = @"rate3_select";
            break;
            
        default:
            imgName = @"ic_like_big";
            
            break;
    }
    
    cell.iconImageView.image = [UIImage imageNamed: imgName];
    cell.placeNameLabel.text = dict[@"venuename"];
    cell.descriptionTextLabel.text = dict[@"description"];

    CFTimeInterval theTimeInterval = [dict[@"date"] doubleValue];
    NSDate* datePublished = [NSDate dateWithTimeIntervalSince1970: theTimeInterval];
    NSString* dateString = [NSDateFormatter localizedStringFromDate: datePublished
                                                          dateStyle: NSDateFormatterMediumStyle
                                                          timeStyle: NSDateFormatterNoStyle];
    cell.dateLabel.text = dateString;
    
    NSInteger like = 0;
    NSInteger dislike = 0;
    NSString* feedbackid = dict[@"feedbackid"];
    
    for (NSDictionary* voteDict in self.votes)
    {
        if ([voteDict[@"feedbackid"] isEqualToString: feedbackid])
        {
            NSInteger vote = [voteDict[@"vote"] integerValue];
            
            if (vote == 1)
            {
                like++;
            }
            else
            {
                dislike++;
            }
        }
    }
    cell.likeCountLabel.text = [NSString stringWithFormat: @"%li", (long)like];
    cell.disLikeCountLabel.text = [NSString stringWithFormat: @"%li", (long)dislike];
    
    return cell;
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
    NSDictionary* dict = _feedbacksDataSource[row];
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
                     
//                     for (FSVenue* venue in _venues)
//                     {
//                         if ([venue.venueId isEqualToString: venueid])
//                         {
//                             self.feedbackShowViewController.venue = venue;
//                             
//                             break;
//                         }
//                     }
                     
                     [self.navigationController pushViewController: self.feedbackShowViewController
                                                          animated: YES];
                     
                     break;
                 }
             }
         }
     }];
}

#pragma mark -

- (void) mainMenuButtonPressed: (id) sender
{
    AIAppDelegate* appDelegate = [AIAppDelegate sharedDelegate];
    [appDelegate toggleLeftSideMenu];
}

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
