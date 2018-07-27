//
//  AIFriendsViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFriendsViewController.h"
#import "AIFriendsTableViewCell.h"
#import "AIApplicationServer.h"
#import "MBProgressHUD.h"
#import "AINetworkMonitor.h"
#import "AIAppDelegate.h"
#import "AIFriendsTableViewController.h"
#import "AIFriendProfileViewController.h"
#import "AIPreferences.h"
#import "Utils.h"
#import "UIViewController+NavButtons.h"

@interface AIFriendsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIView* tableHeaderView;
@property (weak, nonatomic) IBOutlet UIButton* findFriendsButton;

@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) NSDictionary* searchParams;

@property (nonatomic, strong) NSMutableArray* friends;
@property (nonatomic, strong) NSMutableArray* searchresult;

@end

@implementation AIFriendsViewController
{
    AIFriendsTableViewController* _friendsTableViewController;
    AIFriendProfileViewController* _friendProfileViewController;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Friends", nil);
    
    if (self.findFriendsButton)
    {
        [self.findFriendsButton setTitle: NSLocalizedString(@"Find Friends", nil)
                                forState: UIControlStateNormal];
        
        [self setLeftBarButtonItemType: MenuButtonItem
                                action: @selector(mainMenuButtonPressed:)];
    }
    else
    {
        [self setLeftBarButtonItemType: BackButtonItem
                                action: @selector(backButtonPressed:)];
    }
    
    self.searchBar.placeholder = NSLocalizedString(@"Search for friends", nil);
    self.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: self.refreshControl];
    [self.refreshControl addTarget: self
                            action: @selector(handleRefresh:)
                  forControlEvents: UIControlEventValueChanged];
    
    self.friends = [[NSMutableArray alloc] init];
    self.searchresult = [[NSMutableArray alloc] init];
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
    
    [self refreshFriendsList];
}

#pragma mark -

- (void) refreshFriendsList
{
    if (self.user == nil)
    {
        AIUser* currentUser = [AIUser currentUser];
        
        if (currentUser == nil)
        {
            return;
        }
        
        self.user = currentUser;
    }
    
    [self.friends removeAllObjects];
    [self.searchresult removeAllObjects];
    self.searchBar.text = @"";
    [self.tableView reloadData];
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AIApplicationServer sharedInstance] fetchFriendsForUserID: self.user.userid
                                                    resultBlock: ^(NSArray* friends, NSError* error)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (error)
         {
             NSLog(@"Error while reading data about friends: %@", [error localizedDescription]);
         }
         else
         {
             for (AIUser* friend in friends)
             {
                 [self.friends addObject: friend];
             }
             
             [self.tableView reloadData];
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
    
    [self refreshFriendsList];
}

#pragma mark -

- (BOOL) shouldPerformSegueWithIdentifier: (NSString*) identifier
                                   sender: (id) sender
{
    if ([identifier isEqualToString: @"findFriends"])
    {
        if (![[AINetworkMonitor sharedInstance] isInternetConnected])
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark UISearchBarDelegate

- (void) searchBarSearchButtonClicked: (UISearchBar*) searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void) searchBarTextDidBeginEditing: (UISearchBar*) bar
{
    UITextField *searchBarTextField = nil;
    NSArray *views = ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) ? bar.subviews : [[bar.subviews objectAtIndex:0] subviews];
    
    for (UIView *subview in views)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchBarTextField = (UITextField *)subview;
            break;
        }
    }
    
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (void) searchBarTextDidEndEditing: (UISearchBar*) searchBar
{
    [self.searchBar resignFirstResponder];
    
    [self.searchresult removeAllObjects];
    
    NSString* whatSearching = [self.searchBar.text lowercaseString];
    
    if (whatSearching.length > 0)
    {
        for (AIUser* friend in self.friends)
        {
            NSString* name = [[friend userName] lowercaseString];
            
            if ([name rangeOfString: whatSearching].location != NSNotFound)
            {
                [self.searchresult addObject: friend];
            }
        }
        
        if (self.searchresult.count > 0)
        {
        }
        else
        {
            [AIAlertView showAlertWythViewController: self
                                               title: NSLocalizedString(@"Search Results", nil)
                                                text: NSLocalizedString(@"Sorry, the template hasn't found!", nil)];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    if (self.searchresult.count > 0)
    {
        return self.searchresult.count;
    }
    
    return self.friends.count;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return 46.0f;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* cellIdentifier = @"cell";
    
    NSInteger row = indexPath.row;
    
    AIFriendsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                   forIndexPath: indexPath];
    
    AIUser* user = nil;
    
    if (self.searchresult.count > 0)
    {
        user = self.searchresult[row];
    }
    else
    {
        user = self.friends[row];
    }
    
    cell.imageUrl = user.photo_prefix;
    cell.nameLabel.text = [user userName];
    
    return cell;
}

- (void) tableView: (UITableView*) tableView
commitEditingStyle: (UITableViewCellEditingStyle) editingStyle
 forRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger row = indexPath.row;
    NSInteger rows = 0;
    
    if (self.searchresult.count > 0)
    {
        rows = self.searchresult.count;
    }
    else
    {
        rows = self.friends.count;
    }
    
    if (row < rows)
    {
        AIUser* friend = nil;
        
        if (self.searchresult.count > 0)
        {
            friend = self.searchresult[row];
        }
        else
        {
            friend = self.friends[row];
        }
        
        AIUser* currentUser = [AIUser currentUser];
        
        [currentUser removeFriendWithID: friend.userid
                              forUserId: currentUser.userid
                         viewController: self
                            resultBlock: ^(NSError* error)
         {
             if (error)
             {
                 [AIAlertView showAlertWythViewController: self
                                                    title: NSLocalizedString(@"Error", nil)
                                                     text: [error localizedDescription]];
             }
             else
             {
                 [self refreshFriendsList];
             }
         }];
    }
}

- (UITableViewCellEditingStyle) tableView: (UITableView*) tableView editingStyleForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;
    
    NSInteger rows = 0;
    
    if (self.searchresult.count > 0)
    {
        rows = self.searchresult.count;
    }
    else
    {
        rows = self.friends.count;
    }
    
    if ([indexPath row] < rows)
    {
        editingStyle = UITableViewCellEditingStyleDelete;
    }
    
    return editingStyle;
}

- (void) tableView: (UITableView*) tableView didEndEditingRowAtIndexPath: (NSIndexPath*) indexPath
{
    [self.tableView reloadData];
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
    
    if (_friendProfileViewController == nil)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Friends"
                                                             bundle: nil];
        _friendProfileViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFriendProfileVCFriend"];
    }
    
    NSInteger row = indexPath.row;
    
    AIUser* user = nil;
    
    if (self.searchresult.count > 0)
    {
        user = self.searchresult[row];
    }
    else
    {
        user = self.friends[row];
    }
    
    _friendProfileViewController.user = user;
    _friendProfileViewController.isHeMyFriend = YES;
    [self.navigationController pushViewController: _friendProfileViewController
                                         animated: YES];
}

- (IBAction) findFriendsButtonPressed: (id) sender
{
    if (_friendsTableViewController == nil)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Friends"
                                                             bundle: nil];
        _friendsTableViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFriendsTVC"];
    }
    
    _friendsTableViewController.friends = self.friends;
    
    [self.navigationController pushViewController: _friendsTableViewController
                                         animated: YES];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction) cancelButtonPressed: (id) sender
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

- (IBAction) mainMenuButtonPressed: (id)sender
{
    AIAppDelegate* appDelegate = [AIAppDelegate sharedDelegate];
    [appDelegate toggleLeftSideMenu];
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

@end
