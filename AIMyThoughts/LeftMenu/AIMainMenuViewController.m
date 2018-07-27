//
//  AIMainMenuViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIMainMenuViewController.h"
#import "AIMainMenuTableViewCell.h"
#import "AIUsersProfileTableViewCell.h"
#import "AIAppDelegate.h"
#import "AIUser.h"
#import "AIHomeViewController.h"
#import "AGMedallionView+DownloadImage.h"
#import "AIUserProfileViewController.h"
#import "AIFriendsViewController.h"
#import "AIFriendsFeedbacksTableViewController.h"
#import "AILoginViewController.h"
#import "AILogInManager.h"
#import "Utils.h"

static const CGFloat HeightOfTableCell = 44.0;

@interface AIMainMenuViewController () <UITableViewDataSource, UITabBarDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIImageView* logo;
@property (weak, nonatomic) IBOutlet UILabel* verNumberLabel;

@property (strong, nonatomic) AIHomeViewController* homeScreen;

@end

@implementation AIMainMenuViewController
{
    UIAlertView* _logoutAlertView;
    AIUserProfileViewController* _userProfileViewController;
    AIFriendsViewController* _friendsViewController;
    AIFriendsFeedbacksTableViewController* _myThoughtsViewController;
    AILoginViewController* _loginViewController;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString* bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
    NSString* verNumber = [NSString stringWithFormat: NSLocalizedString(@"Ver %@", nil), bundleVersion];
    self.verNumberLabel.text = verNumber;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refreshMenu)
                                                 name: kSignInStateDidChangedNotification
                                               object: nil];

    AIAppDelegate* appDelegate = [AIAppDelegate sharedDelegate];
    UINavigationController* navController = [appDelegate navController];
    NSArray* viewControllers = navController.viewControllers;
    self.homeScreen = (AIHomeViewController*)viewControllers[0];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    UINavigationBar* navBar = self.navigationController.navigationBar;
    UIImage *backgroundImage = [UIImage imageNamed: @"navigation-bar-menu-background.jpg"];
    [navBar setBackgroundImage: backgroundImage
                 forBarMetrics: UIBarMetricsDefault];
    
    [self refreshMenu];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    UINavigationBar* navBar = self.navigationController.navigationBar;
    UIImage *backgroundImage = [UIImage imageNamed: @"navigation-bar-background"];
    [navBar setBackgroundImage: backgroundImage
                 forBarMetrics: UIBarMetricsDefault];
}

- (void) refreshMenu
{
    [self.tableView reloadData];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return 5;
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return HeightOfTableCell;
}

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* cellIdentifier = @"cell";
    static NSString* profileCellIdentifier = @"profileCell";

    NSInteger row = indexPath.row;
	
    if (row == 0)
	{
        AIUsersProfileTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: profileCellIdentifier
                                                                            forIndexPath: indexPath];
        AIUser* currentUser = [AIUser currentUser];
        
        if (currentUser)
        {
            cell.iconView.hidden = NO;
            [cell.iconView asyncDownloadImageURL: currentUser.photo_prefix
                           placeholderImageNamed: @"profile-icon"];
            cell.nameLabel.text = currentUser.userName;
        }
        else
        {
            cell.nameLabel.text = NSLocalizedString(@"Sign In", nil);
            cell.iconView.hidden = YES;
        }
        
        return cell;
        
	}
    else
    {
        
        AIUser* currentUser = [AIUser currentUser];
        BOOL isUserSignedIn = (currentUser != nil);
        AIMainMenuTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                        forIndexPath: indexPath];

        if (row == 1)
        {
            cell.nameLabel.text = NSLocalizedString(@"Home Page", nil);
            cell.iconNameDefault = @"ic_menu_home_activ";
            cell.iconNameSelected = @"ic_menu_home_activ";
            cell.iconNameDisabled = @"ic_menu_home_activ";
        }
        else if (row == 2)
        {
            cell.nameLabel.text = NSLocalizedString(@"Friends", nil);
            cell.iconNameDefault = @"ic_menu_friends_activ";
            cell.iconNameSelected = @"ic_menu_friends_activ";
            cell.iconNameDisabled = @"ic_menu_friends_disable";
            cell.disable = !isUserSignedIn;
        }
        else if (row == 3)
        {
            cell.nameLabel.text = NSLocalizedString(@"My Thoughts", nil);
            cell.iconNameDefault = @"ic_menu_mythoughts_activ";
            cell.iconNameSelected = @"ic_menu_mythoughts_activ";
            cell.iconNameDisabled = @"ic_menu_mythoughts_disable";
            cell.disable = !isUserSignedIn;
        }
        else if (row == 4)
        {
            cell.nameLabel.text = NSLocalizedString(@"Settings", nil);
            cell.iconNameDefault = @"ic_menu_settings_activ";
            cell.iconNameSelected = @"ic_menu_settings_activ";
            cell.iconNameDisabled = @"ic_menu_settings_activ";
        }

        return cell;
    }
	
	return nil;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger row = indexPath.row;

    AIMainMenuTableViewCell* cell = (AIMainMenuTableViewCell*)[tableView cellForRowAtIndexPath: indexPath];

    if (cell.disable)
    {
        return;
    }

    AIUser* currentUser = [AIUser currentUser];
    
    switch (row)
    {
        case 0: // User's Profile
        {
            if (currentUser)
            {
                // Log Out
                [[AILogInManager sharedInstance] logOutAlertWithViewController: self
                                                                  resultBlock: ^
                 {
                 }];

            } else {
                if (_loginViewController == nil)
                {
                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"SignIn"
                                                                         bundle: nil];
                    _loginViewController = [storyboard instantiateViewControllerWithIdentifier: @"LoginVC"];
                }
                AIAppDelegate* appDelegate = [AIAppDelegate sharedDelegate];
                [appDelegate setUpCenterViewController: @[_loginViewController]];
                [appDelegate toggleLeftSideMenu];
            }
        }
            break;
            
        case 1: // Home Page
        {
            AIAppDelegate* appDelegate = [AIAppDelegate sharedDelegate];
            [appDelegate setUpCenterViewController: @[self.homeScreen]];
            [appDelegate toggleLeftSideMenu];
        }
            break;
            
        case 2: // Friends
            if (currentUser)
            {
                if (_friendsViewController == nil)
                {
                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                                         bundle: nil];
                    _friendsViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFriendsVC"];
                }
                AIAppDelegate* appDelegate = [AIAppDelegate sharedDelegate];
                [appDelegate setUpCenterViewController: @[_friendsViewController]];
                [appDelegate toggleLeftSideMenu];
            }

            break;

        case 3: // My Thoughts
            if (currentUser)
            {
                if (_myThoughtsViewController == nil)
                {
                    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Friends"
                                                                         bundle: nil];
                    _myThoughtsViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFriendsFeedbacksTVC"];
                }
                _myThoughtsViewController.user = currentUser;
                _myThoughtsViewController.isItMyThoughts = YES;
                _myThoughtsViewController.needReloadFeedData = YES;
                
                AIAppDelegate* appDelegate = [AIAppDelegate sharedDelegate];
                [appDelegate setUpCenterViewController: @[_myThoughtsViewController]];
                [appDelegate toggleLeftSideMenu];
            }
            
            break;
            
        case 4: // Settings
        {
            [self selectViewControllerInStoryboard: @"Settings_iPhone"
                                    withIdentifier: @"AISettingsVC"];
        }
            
            break;

        default:
            break;
    }
}

- (void) selectViewControllerInStoryboard: (NSString*) aStoryBoardName
                           withIdentifier: (NSString*) anIdentifier
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: aStoryBoardName
                                                         bundle: nil];

    UIViewController* viewController = [storyboard instantiateViewControllerWithIdentifier: anIdentifier];
    
    [self.navigationController pushViewController: viewController
                                         animated: YES];
}

#pragma mark Rotations

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeRight || toInterfaceOrientation ==  UIDeviceOrientationLandscapeLeft)
    {
        self.logo.hidden = YES;
    }
    else
    {
        self.logo.hidden = NO;
    }
}

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
}

#pragma mark Enable only Portrait mode

-(BOOL)shouldAutorotate
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
