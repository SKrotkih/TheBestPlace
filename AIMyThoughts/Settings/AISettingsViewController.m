//
//  AISettingsViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AISettingsViewController.h"
#import "AISettingsMenuTableViewCell.h"
#import "AIPreferences.h"
#import "AIUser.h"
#import "AIHomeViewController.h"
#import "Utils.h"
#import "AILogInManager.h"
#import "UIViewController+NavButtons.h"

static const CGFloat HeightOfTableCell = 44.0;

@interface AISettingsViewController () <UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@end

@implementation AISettingsViewController
{
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Settings", nil);
    
    [self setLeftBarButtonItemType: BackButtonItem
                        action: @selector(backButtonPressed:)];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refreshMenu)
                                                 name: kSignInStateDidChangedNotification
                                               object: nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [AIPreferences setNavigationBarColor: [Utils colorWithRGBHex: kHexSettingsNavBarColor]
                                        forViewController: self];
    
    [self refreshMenu];
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

#pragma mark UITableViewDataSource

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return 3;
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return HeightOfTableCell;
}

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    AIUser* currentUser = [AIUser currentUser];
    BOOL isUserSignedIn = (currentUser != nil);
    BOOL isUserByFacebookSignedIn = currentUser.fb_id.length > 0.0f;
    
    static NSString* cellIdentifier = @"cell";
    AISettingsMenuTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                        forIndexPath: indexPath];
    
    NSInteger row = indexPath.row;
	
    if (row == 0)
	{
		cell.nameLabel.text = NSLocalizedString(@"Change Password", nil);
        cell.iconNameDefault = @"ic_change-pass";
        cell.iconNameDisable = @"ic_change-pass_disable";
        cell.disable = !(isUserSignedIn || isUserByFacebookSignedIn);
	}
	else if (row == 1)
	{
		cell.nameLabel.text = NSLocalizedString(@"Facebook account", nil);
        cell.iconNameDefault = @"ic_facebook";
        cell.iconNameDisable = @"ic_facebook_disable";
	}
	else if (row == 2)
	{
		cell.nameLabel.text = NSLocalizedString(@"Log Out", nil);
        cell.iconNameDefault = @"ic_logout";
        cell.iconNameDisable = @"ic_logout_disable";
        cell.disable = !isUserSignedIn;
	}
	
	return cell;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger row = indexPath.row;

    AISettingsMenuTableViewCell* cell = (AISettingsMenuTableViewCell*)[tableView cellForRowAtIndexPath: indexPath];
    
    if (cell.disable)
    {
//        return;
    }
    
    switch (row)
    {
        case 0: // Change Pasword
        {
            AIUser* currentUser = [AIUser currentUser];
            
            if (currentUser)
            {
                [self changePasswordForUser: currentUser];
            }
        }
            break;
            
        case 1: // Facebook
        {
            [self selectViewControllerInStoryboard: @"Settings_iPhone"
                                    withIdentifier: @"AIFacebookAccountVC"];
        }
            break;
            
        case 2: // Log Out
            [self logOut];
            
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

#pragma mark Log Out

- (void) logOut
{
    [[AILogInManager sharedInstance] logOutAlertWithViewController: self
                                                      resultBlock: ^
    {
        [self refreshMenu];
    }];
}

#pragma mark Change Password

- (void) changePasswordForUser: (AIUser*) currentUser
{
    [self selectViewControllerInStoryboard: @"Settings_iPhone"
                            withIdentifier: @"AITheBestPlaceVC"];
    
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark Enable only Portrait mode

-(BOOL) shouldAutorotate
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
