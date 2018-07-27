//
//  AILikedFeedbacksTableViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/6/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AILikedFeedbacksTableViewController.h"
#import "AILikedFeedbacksTableViewCell.h"
#import "AIFriendsTableViewHeaderCell.h"
#import "AGMedallionView+DownloadImage.h"
#import "UIViewController+NavButtons.h"

@interface AILikedFeedbacksTableViewController ()
@end

@implementation AILikedFeedbacksTableViewController
{
    NSMutableArray* _people;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _people = [[NSMutableArray alloc] init];
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
}

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewDidAppear: animated];

    self.title = self.feedback.venuename;
    
    [self selectPeopleWhomLikedFeedback];
}

- (void) selectPeopleWhomLikedFeedback
{
    [_people removeAllObjects];
    
    for (NSDictionary* dict in self.dataSource)
    {
        NSString* feedbackid = dict[@"feedbackid"];

        if ([feedbackid isEqualToString: self.feedback.feedbackid])
        {
            NSString* firstname = dict[@"firstname"];
            NSString* lastname = dict[@"lastname"];
            NSString* name = dict[@"name"];
            
            if (name.length == 0)
            {
                name = [NSString stringWithFormat: @"%@ %@", firstname, lastname];
            }
            
            NSDictionary* peopleData = @{@"name": name, @"photo": dict[@"photo_prefix"]};
            
            [_people addObject: peopleData];
        }
    }
    
    [self.tableView reloadData];
    
    //             dislikeusers =     (
    //                                 {
    //                                     firstname = Sergey;
    //                                     lastname = Krotkih;
    //                                     name = "Sergey Krotkih";
    //                                     "photo_prefix" = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/t1.0-1/c10.9.111.111/s50x50/1001358_546982228698389_1158811609_s.jpg";
    //                                     "photo_suffix" = "";
    //                                     userid = 9;
    //                                 }
    //             likeusers =     (
    //                              {
    //                                  firstname = Sergey;
    //                                  lastname = Krotkih;
    //                                  name = "Sergey Krotkih";
    //                                  "photo_prefix" = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash2/t1.0-1/c10.9.111.111/s50x50/1001358_546982228698389_1158811609_s.jpg";
    //                                  "photo_suffix" = "";
    //                                  userid = 9;
    //                              }
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return _people.count;
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
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem: 0
                                                 inSection: 0];
    AIFriendsTableViewHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier: @"sectionheader"
                                                                         forIndexPath: indexPath];
    cell.nameLabel.text = [NSString stringWithFormat: (self.isLiked ? NSLocalizedString(@"%i PEOPLE LIKED FEEDBACK", nil) : NSLocalizedString(@"%i PEOPLE DISLIKED FEEDBACK", nil)), _people.count];
    
    return cell;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger row = indexPath.row;
    AILikedFeedbacksTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"LikedFeedbacksCell"
                                                                          forIndexPath: indexPath];
    cell.tag = row;
    cell.delegate = self;
    NSDictionary* dict = _people[row];
    cell.friendNameLabel.text = dict[@"name"];
    NSString* imageUrl = dict[@"photo"];
    [cell.photoFriendsImageView asyncDownloadImageURL: imageUrl
                                placeholderImageNamed: @"profile-icon"];
    
    return cell;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    [tableView deselectRowAtIndexPath: indexPath
                             animated: YES];
}

#pragma mark PressOnLikedFeedbacksDelegate

- (void) pressedOnAddToFriendButtonWithRow: (NSInteger) aRow
{
    NSDictionary* dict = _people[aRow];
    
    NSLog(@"%@", dict[@"name"]);
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
