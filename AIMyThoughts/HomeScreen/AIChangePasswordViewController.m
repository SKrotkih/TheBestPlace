//
//  AIChangePasswordViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIChangePasswordViewController.h"
#import "AIAppDelegate.h"
#import "AITextField.h"
#import "AIUser.h"
#import "AIApplicationServer.h"
#import "AIEditFieldTableViewCell.h"
#import "UIViewController+NavButtons.h"

static const CGFloat HeightOfTableCell = 44.0;

@interface AIChangePasswordViewController () <UITextFieldDelegate, UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* menuBarButtonItem;

- (IBAction) okButtonPressed:(UIButton *)sender;

@end

@implementation AIChangePasswordViewController
{
    UIBarButtonItem* _doneBarButton;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Change Password", nil);
    
    [self.submitButton setTitle: NSLocalizedString(@"Submit", nil)
                       forState: UIControlStateNormal];

    [self setLeftBarButtonItemType: BackButtonItem
                        action: @selector(backButtonPressed:)];
    
    _doneBarButton = [self setRightBarButtonItemType: DoneButtonItem
                                          action: @selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = nil;
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
    static NSString* cellIdentifier = @"cell";
    AIEditFieldTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                     forIndexPath: indexPath];
	
    NSInteger row = indexPath.row;
    
    if (row == 0)
	{
        cell.textField.placeholder = NSLocalizedString(@"Old Password", nil);
        cell.textField.secureTextEntry = YES;
	}
	else if (row == 1)
	{
        cell.textField.placeholder = NSLocalizedString(@"New Password", nil);
        cell.textField.secureTextEntry = YES;
	}
	else if (row == 2)
	{
        cell.textField.placeholder = NSLocalizedString(@"Confirm the new password", nil);
        cell.textField.secureTextEntry = YES;
	}
    cell.tag = row;
    
	return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    NSInteger currentTag = -1;
    
    for (AIEditFieldTableViewCell* cell in [self.tableView visibleCells])
    {
        if ([cell.textField isFirstResponder])
        {
            [cell.textField resignFirstResponder];
            currentTag = cell.tag;
            
            break;
        }
    }
    self.navigationItem.rightBarButtonItem = nil;
    
    if (currentTag >= 0 && currentTag < [self.tableView visibleCells].count - 1)
    {
        currentTag++;
        
        for (AIEditFieldTableViewCell* cell in [self.tableView visibleCells])
        {
            if (cell.tag == currentTag)
            {
                [cell.textField becomeFirstResponder];
                
                break;
            }
        }
    }
    
    return YES;
}

-(void) textFieldDidBeginEditing: (UITextField*) textField
{
    self.navigationItem.rightBarButtonItem = _doneBarButton;
}

- (void) doneButtonPressed: (id) sender
{
    [self resignAllFirstResponder];
}

- (void) resignAllFirstResponder
{
    for (AIEditFieldTableViewCell* cell in [self.tableView visibleCells])
    {
        if ([cell.textField isFirstResponder])
        {
            [cell.textField resignFirstResponder];
            
            break;
        }
    }
    self.navigationItem.rightBarButtonItem = nil;
}

- (UITableViewCell*) cellForIndex: (NSInteger) anIndex
{
    for (UITableViewCell* cell in [self.tableView visibleCells])
    {
        if (cell.tag == anIndex)
        {
            return cell;
        }
    }
    
    return nil;
}

#pragma mark -

- (IBAction) okButtonPressed:(UIButton *)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self resignAllFirstResponder];
    });
    
    AIEditFieldTableViewCell* oldPasswordCell = (AIEditFieldTableViewCell*)[self cellForIndex: 0];
    AITextField* oldPasswordTextField = oldPasswordCell.textField;
    AIEditFieldTableViewCell* newPasswordCell = (AIEditFieldTableViewCell*)[self cellForIndex: 1];
    AITextField* newPasswordTextField = newPasswordCell.textField;
    AIEditFieldTableViewCell* confirmNewPasswordCell = (AIEditFieldTableViewCell*)[self cellForIndex: 2];
    AITextField* confirmNewPasswordTextField = confirmNewPasswordCell.textField;
    
    NSString* oldPassword = oldPasswordTextField.text;
    NSString* newPassword = newPasswordTextField.text;
    NSString* confNewPassword = confirmNewPasswordTextField.text;
    
    if (oldPassword.length == 0)
    {
        [oldPasswordTextField shake];
        
        return;
    }
    
    if (![newPassword isEqualToString: confNewPassword])
    {
        [confirmNewPasswordTextField shake];
        
        return;
    }
    
    AIUser* currentUser = [AIUser currentUser];
    
    [[AIApplicationServer sharedInstance] passwordUserWithID: currentUser.userid
                                                            resultBlock: ^(NSString* aUserPassword, NSError* error)
     {
         if (error)
         {
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error", nil)
                                                 text: [error localizedDescription]];
         }
         else
         {
             if (aUserPassword == nil || (aUserPassword.length > 0 && ![aUserPassword isEqualToString: oldPassword]))
             {
                 [oldPasswordTextField shake];
                 
                 return;
             }
             
             if (newPassword.length == 0)
             {
                 [newPasswordTextField shake];
                 
                 return;
             }
             [[AIApplicationServer sharedInstance] changePasswordUserWithID: currentUser.userid
                                                        newPassword: newPassword
                                                        resultBlock: ^(NSError *error)
              {
                  if (error)
                  {
                      [AIAlertView showAlertWythViewController: self
                                                         title: NSLocalizedString(@"Error", nil)
                                                          text: [error localizedDescription]];
                  }
                  else
                  {
                      [self.navigationController popViewControllerAnimated: YES];
                  }
              }];
         }
     }];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
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

@end
