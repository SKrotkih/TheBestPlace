//
//  AIInviteFriendsFromFoursquare.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/4/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIInviteFriends.h"
#import "MBProgressHUD.h"
#import "AIApplicationServer.h"
#import "AIUser.h"
#import "AIEmailManager.h"

@interface AIInviteFriends ()

@end

@implementation AIInviteFriends

- (id) initWithViewController: (UIViewController*) aParentViewController
{
    if ((self = [super init]))
    {
        self.parentViewController = aParentViewController;
    }
    
    return self;
}

- (void) instantiateViewController
{
    NSAssert(NO, @"You should override this method in a child class!");
}

- (void) generateDataSourse
{
    NSAssert(NO, @"You should override this method in a child class!");
}

#pragma mark AIInviteFriendsDelegate

- (void) handleRefresh: (id) paramSender
{
    [self generateDataSourse];
}

- (void) viewDidLoad
{
    [self generateDataSourse];
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    switch (section)
    {
        case 0:
        {
            NSDictionary* friend = self.friends[row];
            NSString* name = friend[@"name"];
            NSString* email = friend[@"email"];
            
            if (email)
            {
                [[AIEmailManager sharedInstance] sendEmailWithInviteWithEmail: email
                                                                   friendName: name];
            }
            else
            {
                [AIAlertView showAlertWythViewController: self.inviteFriendsTableViewController
                                                   title: NSLocalizedString(@"Sorry", nil)
                                                    text: NSLocalizedString(@"Email is not presented! We can't send invite.", nil)];
            }
        }
            
        case 1:
        {
            
        }
        
            break;
            
        default:
            break;
    }
}

- (void) addRegisteredUsersForFunctor: (UserAndFriendCompareFunctor) aCompareFunctor
{
    if (self.friends.count == 0)
    {
        [_inviteFriendsTableViewController reloadData];
        
        return;
    }
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AIApplicationServer sharedInstance] fetchUsersWithResultBlock: ^(NSArray* aUsers, NSError* error)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (error)
         {
             [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"Error while loading data", nil)
                                          text: [error localizedDescription]];
             [_inviteFriendsTableViewController reloadData];
         }
         else
         {
             for (AIUser* user in aUsers)
             {
                 BOOL isHeFriendAlready = NO;
                 
                 for (AIUser* friend in self.thoughtsBookFriends)
                 {
                     if ([friend.userid isEqualToString: user.userid])
                     {
                         isHeFriendAlready = YES;
                         
                         break;
                     }
                 }
                 
                 if (!isHeFriendAlready)
                 {
                     for (NSDictionary* dict in self.friends)
                     {
                         if (aCompareFunctor(user, dict))
                         {
                             [self.users addObject: user];
                             
                             break;
                         }
                     }
                 }
             }
             
             [_inviteFriendsTableViewController reloadData];
         }
     }];
}

- (void) sendInviteContactPeoplePickerWithViewController: (UIViewController*) aViewController
{
    NSAssert(NO, @"You should override this method in a child class!");
}

@end
