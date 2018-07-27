//
//  AIFeedbackPhotoViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/28/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFeedbackPhotoViewController.h"
#import "UIViewController+NavButtons.h"

@interface AIFeedbackPhotoViewController ()

@end

@implementation AIFeedbackPhotoViewController
{
    UIBarButtonItem* _deleteButtonItem;
}

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {

    }

    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.photoImaveView.image = self.photoImage;
    
    _deleteButtonItem = [self setRightBarButtonItemType: RemoveButtonItem
                                             action: @selector(deleteImage:)];
    self.navigationItem.rightBarButtonItem = nil;
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
    
    self.title = NSLocalizedString(@"View Photo", nil);
}

- (void) viewDidAppear: (BOOL) animated
{
    if (self.isEditable)
    {
        self.navigationItem.rightBarButtonItem = _deleteButtonItem;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) deleteImage: (id) object
{
    [self.delegate deletePhoto];
    [self.navigationController popViewControllerAnimated: YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Enable only Portrait mode

-(BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -

@end
