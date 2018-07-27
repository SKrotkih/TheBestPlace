//
//  AIInviteFriendsFromFoursquare.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/4/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIInviteFriendsFromFoursquare.h"
#import "MBProgressHUD.h"
#import "AIFoursquareAdapter.h"
#import "AIApplicationServer.h"
#import "AIUser.h"
#import "UIImageView+AFNetworking.h"
#import "AINetworkMonitor.h"

@implementation AIInviteFriendsFromFoursquare

- (void) instantiateViewController
{
    self.friends = [[NSMutableArray alloc] init];
    self.users = [[NSMutableArray alloc] init];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Friends"
                                                         bundle: nil];
    self.inviteFriendsTableViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIInviteFriendsTVC"];
    self.inviteFriendsTableViewController.delegate = self;
    self.inviteFriendsTableViewController.friends = self.friends;
    self.inviteFriendsTableViewController.users = self.users;
    
    self.inviteFriendsTableViewController.titleText = NSLocalizedString(@"Foursquare Friends", nil);
    self.inviteFriendsTableViewController.titleSection0 = NSLocalizedString(@"YOU HAVE %i CONTACTS ON Foursquare", nil);
    self.inviteFriendsTableViewController.titleSection1 = NSLocalizedString(@"INVITE FRIENDS VIA EMAIL", nil);
    
    [self.parentViewController.navigationController pushViewController: self.inviteFriendsTableViewController
                                                              animated: YES];
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger section = indexPath.section;
    
    switch (section)
    {
        case 0:
        {
//            NSInteger row = indexPath.row;
        }
            
        case 1:
        {
            [super tableView: tableView didSelectRowAtIndexPath: indexPath];
        }
            
        default:
            break;
    }
}

- (void) generateDataSourse
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    [self.friends removeAllObjects];
    [self.users removeAllObjects];
    [self.inviteFriendsTableViewController reloadData];

    [[AIFoursquareAdapter sharedInstance] getFoursquareUserIdWithResultBlock: ^(NSString* theUserID)
    {
        if (theUserID)
        {
            [MBProgressHUD startProgressWithAnimation: YES];

            [[AIFoursquareAdapter sharedInstance] getFriendsForUserID: theUserID
                                                   resultBlock: ^(BOOL theSuccess, id theResult)
             {
                 [MBProgressHUD stopProgressWithAnimation: YES];
                 
                 if (theSuccess)
                 {
                     NSDictionary* response = (NSDictionary*) theResult[@"response"];
                     NSDictionary* friends = response[@"friends"];
                     NSInteger count = [friends[@"count"] intValue];
                     
                     if (count == 0)
                     {
                         NSLog(@"Sorry, we have not information about your friends on Foursquare!");
                     }
                     else
                     {
                         NSArray* items = friends[@"items"];
                         
                         for (NSDictionary* dict in items)
                         {
                             NSDictionary* contact = dict[@"contact"];
                             NSString* email = contact[@"email"];
                             
                             if (email)
                             {
                                 NSString* name = [NSString stringWithFormat: @"%@ %@", dict[@"firstName"], dict[@"lastName"]];
                                 NSDictionary* photo = dict[@"photo"];
                                 NSString*  prefix = photo[@"prefix"];
                                 NSString*  suffix = photo[@"suffix"];
                                 NSString* photourl = [NSString stringWithFormat: @"%@32%@", prefix, suffix];
                                 NSDictionary* friendData = @{@"name": name, @"photourl": photourl, @"email": email};
                                 [self.friends addObject: friendData];
                             }
                         }
                         
                         [self addRegisteredUsersForFunctor: ^BOOL(AIUser* user, NSDictionary* friend){
                             
                             NSString* email = user.email;
                             
                             if ([email isEqualToString: friend[@"email"]])
                             {
                                 return YES;
                             }
                             
                             return NO;
                         }];
                     }
                 }
             }];
        }
    }];
}

@end
