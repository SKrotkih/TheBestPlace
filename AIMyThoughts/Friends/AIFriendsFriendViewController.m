//
//  AIFriendsFriendViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFriendsFriendViewController.h"
#import "AIFriendsTableViewCell.h"
#import "AIApplicationServer.h"
#import "MBProgressHUD.h"
#import "AINetworkMonitor.h"
#import "AIAppDelegate.h"
#import "AIFriendProfileViewController.h"
#import "UIViewController+NavButtons.h"

@interface AIFriendsFriendViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIView* tableHeaderView;
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) NSDictionary* searchParams;

@end

@implementation AIFriendsFriendViewController
{
    AIFriendProfileViewController* _friendProfileViewController;
    NSMutableArray* _friends;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Friends", nil);
    
    [self setLeftBarButtonItemType: BackButtonItem
                        action: @selector(backButtonPressed:)];

    self.searchBar.placeholder = NSLocalizedString(@"Search for friends", nil);
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: self.refreshControl];
    [self.refreshControl addTarget: self
                            action: @selector(handleRefresh:)
                  forControlEvents: UIControlEventValueChanged];
    
    _friends = [[NSMutableArray alloc] init];

    NSDictionary* dict = @{@"name": @"Friend Name", @"photourl": @"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/t1.0-1/c10.9.111.111/s50x50/1001358_546982228698389_1158811609_s.jpg"};
    [_friends addObject: dict];
    NSDictionary* dict2 = @{@"name": @"Friend Name", @"photourl": @""};
    [_friends addObject: dict2];
    NSDictionary* dict3 = @{@"name": @"Friend Name", @"photourl": @"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/t1.0-1/c10.9.111.111/s50x50/1001358_546982228698389_1158811609_s.jpg"};
    [_friends addObject: dict3];
    
    [self.tableView reloadData];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
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
    
    NSString* whatSearching = self.searchBar.text;

    NSLog(@"%@", whatSearching);
}

#pragma mark - Table view data source

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return _friends.count;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.0f;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* cellIdentifier = @"cell";

    NSInteger row = indexPath.row;
    
    AIFriendsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                   forIndexPath: indexPath];
    
    NSDictionary* dict = _friends[row];
    NSString* name = dict[@"name"];
    NSString* photoUrlString = dict[@"photourl"];
    
    cell.imageUrl = photoUrlString;
    cell.nameLabel.text = name;
    
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
    
    if (_friendProfileViewController == nil)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Friends"
                                                             bundle: nil];
        _friendProfileViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFriendProfileVC"];
    }
    _friendProfileViewController.isHeMyFriend = NO;
    [self.navigationController pushViewController: _friendProfileViewController
                                         animated: YES];
}

#pragma mark -

- (IBAction) cancelButtonPressed: (id) sender
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
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
