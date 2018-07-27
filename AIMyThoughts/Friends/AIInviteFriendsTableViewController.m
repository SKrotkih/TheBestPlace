//
//  AIInviteFriendsTableViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/4/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIInviteFriendsTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AIInviteFriendsTableViewCell.h"
#import "AINetworkMonitor.h"
#import "AIFriendsTableViewHeaderCell.h"
#import "AIUser.h"
#import "UIViewController+NavButtons.h"

@interface AIInviteFriendsTableViewController ()

@end

@implementation AIInviteFriendsTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: self.refreshControl];
    [self.refreshControl addTarget: self
                            action: @selector(handleRefresh:)
                  forControlEvents: UIControlEventValueChanged];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    self.title = self.titleText;
    
    [self.delegate viewDidLoad];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) reloadData
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource delegate

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    NSInteger numberOfRows = 0;
    
    switch (section)
    {
        case 0:
            numberOfRows = self.friends.count;
            break;
            
        case 1:
            numberOfRows = self.users.count;
            break;

        default:
            break;
    }
    
    return numberOfRows;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    NSInteger sections = 0;
    
    if (self.friends.count > 0)
    {
        sections++;
    }
    
    if (self.users.count > 0)
    {
        sections++;
    }
    
    return sections;
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return 56.0f;
}

- (CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection: (NSInteger) section
{
    return 32.0f;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section
{
    NSString* title = nil;
    
    switch (section)
    {
        case 0:
            title = [NSString stringWithFormat: self.titleSection0, self.friends.count];
            break;
            
        case 1:
            title = self.titleSection1;
            break;
            
        default:
            break;
    }

    NSIndexPath* indexPath = [NSIndexPath indexPathForItem: 0
                                                 inSection: 0];
    AIFriendsTableViewHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier: @"sectionheader"
                                                                         forIndexPath: indexPath];
    cell.nameLabel.text = title;
    
    return cell;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* cellIdentifier = @"cell";
    
    NSInteger section =  indexPath.section;
    NSInteger row =  indexPath.row;
    AIInviteFriendsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                         forIndexPath: indexPath];
    cell.accessImageView.image = [UIImage imageNamed: @"ic_add"];

    switch (section)
    {
        case 0:
        {
            NSDictionary* dict = self.friends[row];
            cell.nameLabel.text = dict[@"name"];
            NSString* photoUrlString = dict[@"photourl"];
            cell.imageUrl = photoUrlString;
            
            return cell;
        }
            
        case 1:
        {
            AIUser* user = self.users[row];
            cell.nameLabel.text = [user userName];
            NSString* photoUrlString = user.photo_prefix;
            cell.imageUrl = photoUrlString;
            
            return cell;
            
        }
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    [tableView deselectRowAtIndexPath: indexPath
                             animated: YES];

    [self.delegate tableView: tableView didSelectRowAtIndexPath: indexPath];
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
    
    [self.delegate handleRefresh: paramSender];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
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
