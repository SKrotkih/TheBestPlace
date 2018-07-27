//
//  AITakePhotoViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/27/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AITakePhotoViewController.h"

@interface AITakePhotoViewController ()

@property(nonatomic, weak) UIImagePickerController* imagePickerController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *snapeBarButtonItem;


@end

@implementation AITakePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             delegate: (id<AITakeFotoControllerDelegate>) aDelegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.delelgate = aDelegate;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view bringSubviewToFront: self.toolBar];
    
    [self.doneBarButtonItem setTitle: NSLocalizedString(@"Close", nil)];
    [self.snapeBarButtonItem setTitle: NSLocalizedString(@"Snape", nil)];
}

- (void)didReceiveMemoryWarning
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

- (IBAction) doneButtonPressed: (id)sender
{
    [self.delelgate done];
}

- (IBAction) takePhotoButtonPressed: (id) sender
{
    [self.delelgate takePhoto];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
}

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
