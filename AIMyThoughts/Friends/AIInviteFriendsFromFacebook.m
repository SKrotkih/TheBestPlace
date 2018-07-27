//
//  AIInviteFacebookTableViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/4/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIInviteFriendsFromFacebook.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "AINetworkMonitor.h"
#import "AIApplicationServer.h"
#import "AIUser.h"
#import "NSArray+SHFastEnumerationProtocols.h"

@interface AIInviteFriendsFromFacebook ()
@end

@implementation AIInviteFriendsFromFacebook
{
}

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
    
    self.inviteFriendsTableViewController.titleText = NSLocalizedString(@"Facebook Friends", nil);
    self.inviteFriendsTableViewController.titleSection0 = NSLocalizedString(@"YOU HAVE %i CONTACTS ON Facebook", nil);
    self.inviteFriendsTableViewController.titleSection1 = NSLocalizedString(@"INVITE FRIENDS VIA EMAIL", nil);
    
    [self.parentViewController.navigationController pushViewController: self.inviteFriendsTableViewController
                                                              animated: YES];
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

    if ([FBSDKAccessToken currentAccessToken])
    {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self gettingFacebookFriendsList];
        });
    }
}

- (void) gettingFacebookFriendsList
{
    [MBProgressHUD startProgressWithAnimation: YES];
    
    NSMutableString *facebookRequest = [NSMutableString new];
    [facebookRequest appendString: @"/me/friends"]; // taggable_friends
    [facebookRequest appendString: @"?limit=100"];
    NSDictionary* parameters = @{@"fields": @"picture,id,birthday,email,name,gender,first_name,last_name"};

    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath: facebookRequest
                                                                   parameters: parameters
                                                                   HTTPMethod: @"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *innerConnection, NSDictionary *result, NSError *error){
        [MBProgressHUD stopProgressWithAnimation: YES];
        
        if (error)
        {
            NSLog(@"%@", [error localizedDescription]);
            return;
        }
        
        if (result)
        {
            NSArray* friends = [result objectForKey: @"data"];
            
            if (friends.count == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [AIAlertView showAlertWythViewController: self.inviteFriendsTableViewController
                                                       title: NSLocalizedString(@"No friends", nil)
                                                        text: NSLocalizedString(@"If your friends logged in 'The Best Place' by using Facebook, you would be able to add them to friends.", nil)];
                    [self.parentViewController.navigationController popViewControllerAnimated: YES];
                });
                
                return;
            }
            for (NSDictionary* friend in friends)
            {
                NSString* facebookuserid = friend[@"id"];
                
                if ((facebookuserid == nil) || (facebookuserid.length == 0))
                {
                    continue;
                }
                
                NSDictionary* picture = friend[@"picture"];
                NSDictionary* pictureData = picture[@"data"];
                NSString* pictureUrl = pictureData[@"url"];
                
                if (pictureUrl == nil)
                {
                    pictureUrl = @"";
                }
                
                NSString* name = friend[@"name"];
                
                if (name == nil)
                {
                    name = [NSString stringWithFormat: @"%@ %@", friend[@"first_name"], friend[@"last_name"]];
                }
                
                NSString* facebookusername = friend[@"username"];
                
                if (facebookusername == nil)
                {
                    facebookusername = @"";
                }
                
                NSDictionary* dict = @{@"name": name, @"facebookuserid": facebookuserid, @"facebookusername": facebookusername, @"photourl": pictureUrl};
                [self.friends addObject: dict];
            }
            
            [self addRegisteredUsersForFunctor: ^BOOL(AIUser* user, NSDictionary* friend){
                
                NSString* facebookuserid = user.fb_id;
                
                if ([facebookuserid isEqualToString: friend[@"facebookuserid"]])
                {
                    return YES;
                }
                
                return NO;
            }];
        }
    }];
}

@end
