//
//  User.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIUser.h"
#import "NSDictionary+VSNullGetter.h"
#import "UIAlertView+SHAlertViewBlocks.h"
#import "AIApplicationServer.h"
#import "MBProgressHUD.h"
#import "AILocalDataBase.h"

@implementation AIUser

@synthesize userid;
@synthesize contact;
@synthesize name;
@synthesize fb_id;
@synthesize firstname;
@synthesize lastname;
@synthesize gender;
@synthesize homeCity;
@synthesize photo_prefix = _photo_prefix;
@synthesize photo_suffix = _photo_suffix;
@synthesize email;
@synthesize currentUser;

- (id) initWithObject: (User*) aUser
{
    if ((self = [self init]))
    {
        self.userid = aUser.userid;
        self.contact = aUser.contact;
        self.firstname = aUser.firstname;
        self.gender = aUser.gender;
        self.homeCity = aUser.homeCity;
        self.lastname = aUser.lastname;
        self.photo_prefix = aUser.photo_prefix;
        self.photo_suffix = aUser.photo_suffix;
        self.email = aUser.email;
        self.name = aUser.name;
        self.fb_id = aUser.fb_id;
        self.currentUser = [aUser.currentUser boolValue];
    }
    
    return self;
}

- (id) initWithFacebookInfo: (NSDictionary*) graphUser
{
    if ((self = [self init]))
    {
        //                            {
        //                                birthday = "02/02/1958";
        //                                email = "svmp@ukr.net";
        //                                "first_name" = Sergey;
        //                                gender = male;
        //                                id = 100001598500686;
        //                                "last_name" = Krotkih;
        //                                name = "Sergey Krotkih";
        //                                picture =     {
        //                                    data =         {
        //                                        "is_silhouette" = 0;
        //                                        url = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/t1.0-1/c10.9.111.111/s50x50/1001358_546982228698389_1158811609_s.jpg";
        //                                    };
        //                                };
        //                                username = "sergey.krotkih";
        //                            }
        
        [self updateWithFacebookInfo: graphUser];
        self.currentUser = NO;
    }
    
    return self;
}

- (id) initWithDict: (NSDictionary*) dict
{
    if ((self = [self init]))
    {
        self.userid = dict[@"id"];
        self.fb_id = dict[@"fb_id"];
        self.name = dict[@"name"];
        self.email = dict[@"email"];
        self.firstname = dict[@"firstname"];
        self.lastname = dict[@"lastname"];
        self.contact = dict[@"contact"];
        self.gender = dict[@"gender"];
        self.homeCity = dict[@"homeCity"];
        self.photo_prefix = dict[@"photo_prefix"];
        self.photo_suffix = dict[@"photo_suffix"];
        
        self.currentUser = NO;
    }
    
    return self;
}

- (void) updateWithFacebookInfo: (NSDictionary*) graphUser
{
    self.firstname = graphUser[@"first_name"];
    self.lastname = graphUser[@"last_name"];
    self.gender = graphUser[@"gender"];
    self.email = graphUser[@"email"];
    NSDictionary* picture = graphUser[@"picture"];
    NSDictionary* picture_data = picture[@"data"];
    self.photo_prefix = picture_data[@"url"];
    self.name = graphUser[@"username"];
    self.fb_id = [NSString stringWithFormat: @"%@", graphUser[@"id"]];
}

- (void) updateWithInfo: (NSDictionary*) userInfo
{
    NSDictionary* profile = [userInfo objectForKey: @"profile"];
    
    if ([profile valueForKey: @"name"] != [NSNull null])
    {
        self.name = [profile nonNullObjectForKey: @"name"];
    }
    else
    {
        self.name = [userInfo nonNullObjectForKey: @"username"];
    }
    
    self.email = [userInfo nonNullObjectForKey: @"email"];
    
    if ([profile objectForKey: @"photo"] != [NSNull null])
    {
        NSString* photoPath = [NSString stringWithFormat: @"%@/%@", [[AIApplicationServer sharedInstance] imagesStorageFolder], [profile nonNullObjectForKey: @"photo"]];
        self.photo_prefix = photoPath;
    }
}

- (NSString*) userName
{
    NSString* userName = @"";
    
    if (self.firstname.length > 0 || self.lastname.length > 0)
    {
        userName = [NSString stringWithFormat: @"%@ %@", self.firstname, self.lastname];
    }
    else if (self.name.length > 0)
    {
        userName = self.name;
    }
    
    return userName;
}

- (NSString*) photo_prefix
{
    if (_photo_prefix == nil || _photo_prefix.length == 0)
    {
        return @"";
    }
    else
    {
        return _photo_prefix;
    }
}


- (void) addFriend: (AIUser*) aFriend
{
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AIApplicationServer sharedInstance]  addFriendWithID: aFriend.userid
                                                 forUserId: self.userid
                                               resultBlock: ^(NSError* theError)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (theError == nil)
         {
             [[UIAlertView SH_alertViewWithTitle: NSLocalizedString(@"Congrats!", nil)
                                      andMessage: [NSString stringWithFormat: NSLocalizedString(@"You and %@ are friends now", nil), [aFriend userName]]
                                    buttonTitles: @[@"OK"]
                                     cancelTitle: nil
                                       withBlock: ^(NSInteger theButtonIndex)
               {
               }] show];
         }
         else
         {
             [[UIAlertView SH_alertViewWithTitle: NSLocalizedString(@"Warning", nil)
                                      andMessage: [theError localizedDescription]
                                    buttonTitles: @[@"OK"]
                                     cancelTitle: nil
                                       withBlock: ^(NSInteger theButtonIndex)
               {
               }] show];
         }
     }];
}

- (void) removeFriendWithID: (NSString*) aFriendId
                  forUserId: (NSString*) aUserId
             viewController: (UIViewController*) aViewController
                resultBlock: (void (^)(NSError *error)) callback
{
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AIApplicationServer sharedInstance] removeFriendWithID: aFriendId
                                                   forUserId: aUserId
                                                 resultBlock: ^(NSError* error)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         callback(error);
     }];
}

#pragma mark Current User

+ (AIUser*) currentUser
{
    return [[AILocalDataBase sharedInstance] currentUser];
}

@end
