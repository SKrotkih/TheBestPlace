//
//  AIFriendsTableViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/4/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFriendsTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "UIImageView+AFNetworking.h"
#import "AIFriendsSuggTableViewCell.h"
#import "AIFriendsTableViewHeaderCell.h"
#import "AIFindFriendsTableViewCell.h"
#import "MBProgressHUD.h"
#import "AIApplicationServer.h"
#import "AINetworkMonitor.h"
#import "AIInviteFriendsFromFacebook.h"
#import "AIInviteFriendsFromFoursquare.h"
#import "AIInviteFriendsFromContacts.h"
#import "AIInviteFriendsTableViewController.h"
#import "AIEmailManager.h"
#import "NSString+Validator.h"
#import "UIViewController+NavButtons.h"

@interface AIFriendsTableViewController () <MFMailComposeViewControllerDelegate>
@end

@implementation AIFriendsTableViewController
{
    AIInviteFriends* _inviteFriendsFromFacebook;
    AIInviteFriends* _inviteFriendsFromFoursquare;
    AIInviteFriends* _inviteFriendsFromContacts;
    NSMutableArray* _users;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _users = [[NSMutableArray alloc] init];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: self.refreshControl];
    [self.refreshControl addTarget: self
                            action: @selector(handleRefresh:)
                  forControlEvents: UIControlEventValueChanged];
    
    self.title = NSLocalizedString(@"Add Friends", nil);
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self allUsersRequestData];
}

- (void) handleRefresh: (id) paramSender
{
    [self.refreshControl endRefreshing];
    
    [self allUsersRequestData];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    NSInteger numberOfRows = 0;
    
    switch (section)
    {
        case 0:
            numberOfRows = 5;
            break;
            
        case 1:
            numberOfRows = 1;
            break;

        case 2:
            numberOfRows = _users.count;
            break;
            
        default:
            break;
    }
    
    return numberOfRows;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    NSInteger sections = 2;

    if (_users.count > 0)
    {
        sections++;
    }
    
    return sections;
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return 46.0f;
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
            title = NSLocalizedString(@"FIND FRIENDS", nil);
            break;
            
        case 1:
            title = NSLocalizedString(@"INVITE FRIENDS", nil);
            break;
            
        case 2:
            title = NSLocalizedString(@"FRIENDS SUGGESTIONS", nil);
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
    static NSString* cellIdentifierSugg = @"cellsugg";
    
    NSInteger section =  indexPath.section;
    NSInteger row =  indexPath.row;
    
    switch (section)
    {
        case 0:
        {
            AIFindFriendsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                           forIndexPath: indexPath];

            NSString* title = nil;
            NSString* imageName = nil;
            
            switch (row)
            {
                case 0:
                    title = NSLocalizedString(@"Invite friends from Facebook", nil);
                    imageName = @"icon-facebook-hover";
                    break;

                case 1:
                    title = NSLocalizedString(@"Invite friends from contacts", nil);
                    imageName = @"ic_contacts";
                    break;

                case 2:
                    title = NSLocalizedString(@"Invite friends from Address Book", nil);
                    imageName = @"ic_contacts";
                    break;
                    
                case 3:
                    title = NSLocalizedString(@"Invite friends from Foursquare", nil);
                    imageName = @"icon-foursquare-hover";
                    break;

                case 4:
                    title = NSLocalizedString(@"Search friends by name or email", nil);
                    imageName = @"ic_search";
                    break;
                    
                default:
                    break;
            }
            cell.nameLabel.text = title;
            cell.iconImageView.image = [UIImage imageNamed: imageName];
            
            return cell;
        }
            
        case 1:
        {
            AIFindFriendsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                               forIndexPath: indexPath];
            cell.nameLabel.text = NSLocalizedString(@"Invite friends by email", nil);
            NSString* imageName = @"ic_email";
            cell.iconImageView.image = [UIImage imageNamed: imageName];

            return cell;
        }
            
        case 2:
        {
            if (_users.count == 0)
            {
                return nil;
            }
            
            AIFriendsSuggTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifierSugg
                                                                               forIndexPath: indexPath];

            AIUser* user = _users[row];
            NSString* name = [user userName];
            NSString* mutuable = 0; //dict[@"mutuable"];
            NSString* photoUrlString = user.photo_prefix;
            
            cell.imageUrl = photoUrlString;
            cell.nameLabel.text = name;
            cell.indexPath = indexPath;
            cell.subTitleLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%i mutual friends", nil), [mutuable integerValue]];
            
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

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    switch (section)
    {
        case 0:
        {
            switch (row)
            {
                case 0:   // Invite friends from Facebook
                {
                    if (_inviteFriendsFromFacebook == nil)
                    {
                        _inviteFriendsFromFacebook = [[AIInviteFriendsFromFacebook alloc] initWithViewController: self];
                    }
                    _inviteFriendsFromFacebook.thoughtsBookFriends = self.friends;

                    [_inviteFriendsFromFacebook instantiateViewController];
                }
                    break;
                    
                case 1:     // Invite friends from contacts
                {
                    if (_inviteFriendsFromContacts == nil)
                    {
                        _inviteFriendsFromContacts = [[AIInviteFriendsFromContacts alloc] initWithViewController: self];
                    }
                    _inviteFriendsFromContacts.thoughtsBookFriends = self.friends;
                    
                    [_inviteFriendsFromContacts instantiateViewController];
                }
                    
                    break;

                case 2:     // Invite friends from Address Book
                {
                    if (_inviteFriendsFromContacts == nil)
                    {
                        _inviteFriendsFromContacts = [[AIInviteFriendsFromContacts alloc] initWithViewController: self];
                    }
                    [_inviteFriendsFromContacts sendInviteContactPeoplePickerWithViewController: self];
                }
                    
                    break;
                    
                case 3:    // Invite friends from Foursquare
                {
                    if (_inviteFriendsFromFoursquare == nil)
                    {
                        _inviteFriendsFromFoursquare = [[AIInviteFriendsFromFoursquare alloc] initWithViewController: self];
                    }
                    _inviteFriendsFromFoursquare.thoughtsBookFriends = self.friends;
                    
                    [_inviteFriendsFromFoursquare instantiateViewController];
                }
                    
                    break;
                    
                case 4:   // Search friends by name or email
                {
                    NSLog(@"Search friends by name or email");
                }
                    
                    break;
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 1:  // Invite friends by email
        {
            [AIAlertView showAlertWythViewController: self
                                               title: NSLocalizedString(@"Invite friende by email", nil)
                                                text: NSLocalizedString(@"Please enter friend's email and name:", nil)
                              enterEmailAndNameBlock: ^(NSString* email, NSString* name)
            {

                if ([email validateEmail] && [email validateNonEmpty] && name.length > 0)
                {
                    [[AIEmailManager sharedInstance] sendEmailWithInviteWithEmail: email
                                                                       friendName: name];
                }
                else
                {
                    [AIAlertView showAlertWythViewController: self
                                                       title: NSLocalizedString(@"Warning", nil)
                                                        text: NSLocalizedString(@"Please, enter valid email and name.", nil)];
                    
                }
            }
                                   cancelButtonBlock: ^()
            {
                                       
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark Users

- (void) allUsersRequestData
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }

    [_users removeAllObjects];
    [self.tableView reloadData];
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AIApplicationServer sharedInstance] fetchUsersWithResultBlock: ^(NSArray* aUsers, NSError* error)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (error == nil)
         {
             for (AIUser* user in aUsers)
             {
                 BOOL isHeFriendAlready = NO;
                 
                 for (AIUser* friend in self.friends)
                 {
                     if ([friend.userid isEqualToString: user.userid])
                     {
                         isHeFriendAlready = YES;
                         
                         break;
                     }
                 }
                 
                 if (!isHeFriendAlready)
                 {
                     [_users addObject: user];
                 }
             }
             
             [self.tableView reloadData];
         }
     }];
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

#pragma mark AIAddFriendsSuggestionDelegate protocol

- (void) addButtonPressedOnCellWithIndexPath: (NSIndexPath *) anIndexPath
{
    if (!anIndexPath)
    {
        return;
    }
    
    NSInteger row = anIndexPath.row;

    if (row < _users.count)
    {
        AIUser* user = _users[row];
        AIUser* currentUser = [AIUser currentUser];
        [currentUser addFriend: user];
    }
}

- (void) excludeButtonPressedOnCellWithIndexPath: (NSIndexPath *) anIndexPath
{
    if (!anIndexPath || _users.count == 0)
    {
        return;
    }
    NSInteger row = anIndexPath.row;
    [_users removeObjectAtIndex: row];
    [self.tableView reloadData];
}

#pragma mark -

@end
