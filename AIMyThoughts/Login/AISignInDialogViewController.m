//
//  AISignInDialogViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 5/5/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AISignInDialogViewController.h"
#import <sys/utsname.h>
#import "Utils.h"
#import "AIPreferences.h"
#import "UIViewController+NavButtons.h"

const CGFloat kTabBarHeight = 0.0f;

@interface AISignInDialogViewController ()

@end

@implementation AISignInDialogViewController
{
    BOOL _keyboardIsShown;
    CGRect _scrollViewFrame;
    UIBarButtonItem* _doneBarButton;
    UITextField* _currentTextField;
    NSMutableArray* _allTextFileds;
    UITextField* _defaultTextField;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _keyboardIsShown = NO;
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
    
    _doneBarButton = [self setRightBarButtonItemType: DoneButtonItem
                                              action: @selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = nil;
    
    _scrollViewFrame = self.scrollView.frame;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [AIPreferences setNavigationBarColor: [Utils colorWithRGBHex: kHexSettingsNavBarColor]
                       forViewController: self];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: self.view.window];
}


- (void) viewDidDisappear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
    
    [super viewDidDisappear: animated];
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

#pragma mark Autoscroll

- (void) keyboardWillShow: (NSNotification*) aNotification
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the `UIScrollView`
    // if the keyboard is already shown.  This can happen if the user, after fixing editing a `UITextField`,
    // scrolls the resized `UIScrollView` to another `UITextField` and attempts to edit the next `UITextField`.
    // If we were to resize the `UIScrollView` again, it would be disastrous.
    // NOTE: The keyboard notification will fire even when the keyboard is already shown.
    
    if (_keyboardIsShown)
    {
        return;
    }
    
    NSDictionary* userInfo = [aNotification userInfo];
    
    // get the size of the keyboard
    CGFloat keyboardHight = [[userInfo objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    // resize the noteView
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height -= (keyboardHight - kTabBarHeight);
    
    [UIView beginAnimations: nil
                    context: NULL];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [self.scrollView setFrame: viewFrame];
    [UIView commitAnimations];
    
    _keyboardIsShown = YES;
}

- (void) keyboardWillHide: (NSNotification*) aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    // get the size of the keyboard
    CGFloat keyboardHight = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    // resize the scrollview
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height += (keyboardHight - kTabBarHeight);
    
    [UIView beginAnimations: nil
                    context: NULL];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [self.scrollView setFrame: viewFrame];
    [UIView commitAnimations];
    
    self.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    
    _keyboardIsShown = NO;
}

#pragma mark Navigation on the textFilelds

- (void) listSubviewsOfView: (UIView*) view
{
    NSArray *subviews = [view subviews];
    
    if ([subviews count] == 0)
    {
        return;
    }
    
    for (UIView* subView in subviews)
    {
        if ([subView isKindOfClass: [UITextField class]])
        {
            [_allTextFileds addObject: subView];
            
            if (subView.tag == 0)
            {
                _defaultTextField = (UITextField*)subView;
            }
        }
        
        [self listSubviewsOfView: subView];
    }
}

- (UITextField*) nextTextFieldForCurrebtTextField: (UITextField*) textField
{
    if (_allTextFileds == nil)
    {
        _allTextFileds = [[NSMutableArray alloc] init];
        
        [self listSubviewsOfView: self.view];
    }
    
    UITextField* nextTextField = nil;
    NSInteger tag = textField.tag;
    tag++;
    
    for (UITextField* currTextField in _allTextFileds)
    {
        if (currTextField.tag == tag)
        {
            nextTextField = currTextField;
        }
    }
    
    return nextTextField;
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    NSArray* constraints = self.view.constraints;
    NSLog(@"========\n%@\n========", constraints);
}

#pragma mark - UITextFieldDelegate

- (NSString*) machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString: systemInfo.machine
                              encoding: NSUTF8StringEncoding];
}

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    UITextField* nextTextField = [self nextTextFieldForCurrebtTextField: textField];
    
    if (nextTextField == nil)
    {
        [textField resignFirstResponder];
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        CGFloat tfY = CGRectGetMinY(nextTextField.frame);
        self.scrollView.contentOffset = CGPointMake(0.0f, tfY + 44.0f + ([[self machineName] isEqualToString: @"iPhone4,1"] ? 100.0f : 0.0f));
        [nextTextField becomeFirstResponder];
    }
    
    return NO;
}

- (void) textFieldDidBeginEditing: (UITextField*) textField
{
    self.navigationItem.rightBarButtonItem = _doneBarButton;
    _currentTextField = textField;
}

- (void) textFieldDidEndEditing: (UITextField*) textField
{
    _currentTextField = nil;
}

#pragma mark -

- (void) doneButtonPressed: (id) sender
{
    [_currentTextField resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
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

@end
