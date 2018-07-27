//
//  AIPhotoMakerController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/8/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIPhotoMakerController.h"
#import "AITakePhotoViewController.h"
#import "UIDevice+Orientation.h"
#import "UIImage+ScaleToFit.h"

const BOOL kNeedCameraControols = YES;

@interface AIPhotoMakerController () <AITakeFotoControllerDelegate>

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, weak) id<AISavePhotoDelegate> delegate;

@end

@implementation AIPhotoMakerController
{
    __strong AITakePhotoViewController* _takePhotoVC;
    UIViewController* _parentViewController;
}

- (id) initWithViewController: (UIViewController*) aParentViewController
                     delegate: (id<AISavePhotoDelegate>) aDelegate
{
    if ((self = [super init]))
    {
        _parentViewController = aParentViewController;
        self.delegate = aDelegate;
    }
    
    return self;
}

- (void) showImagePickerForPhotoPicker
{
    [self showImagePickerForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void) showImagePickerForCamera
{
    [self showImagePickerForSourceType: UIImagePickerControllerSourceTypeCamera];
}

- (void) showImagePickerForSourceType: (UIImagePickerControllerSourceType) sourceType
{
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        if (kNeedCameraControols)
        {
            imagePickerController.showsCameraControls = YES;
        }
        else
        {
            imagePickerController.showsCameraControls = NO;
            /*
             The user wants to use the camera interface. Set up our custom overlay view for the camera.
             */
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                                 bundle: nil];
            _takePhotoVC = [storyboard instantiateViewControllerWithIdentifier: @"AITakePhotoVC"];
            _takePhotoVC.delelgate = self;
            self.overlayView = _takePhotoVC.view;
            self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
            imagePickerController.cameraOverlayView = self.overlayView;
        }
    }
    
    self.imagePickerController = imagePickerController;
    
    [_parentViewController presentViewController: self.imagePickerController
                                        animated: YES
                                      completion: nil];
}

#pragma mark - Toolbar actions

- (void) done
{
    [_parentViewController dismissViewControllerAnimated: YES
                                              completion: NULL];
    _takePhotoVC = nil;
    self.imagePickerController = nil;
}

- (void) takePhoto
{
    [self.imagePickerController takePicture];
}

#pragma mark - UIImagePickerControllerDelegate


// This method is called when an image has been chosen from the library or taken from the camera.

- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    UIImage* photoImage = [info valueForKey: UIImagePickerControllerEditedImage];

    if (photoImage == nil)
    {
        photoImage = [info valueForKey: UIImagePickerControllerOriginalImage];
    }
    
    self.photoImage = photoImage;
    
    CGSize screenSize = [[UIDevice currentDevice] screenFrame].size;
    NSDictionary* metadata = [info valueForKey: UIImagePickerControllerMediaMetadata];
    NSInteger orientation = [metadata[@"Orientation"] integerValue];
    
    if (orientation == 1 || orientation == 3)
    {
        CGFloat width = screenSize.width;
        screenSize.width = screenSize.height;
        screenSize.height = width;
    }
    UIImage* image = [self.photoImage imageByScalingProportionallyToSize: screenSize];
    
    if (self.delegate)
    {
        [self.delegate savePhoto: image];
    }
    
    [self done];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) picker
{
    [_parentViewController dismissViewControllerAnimated: YES
                                              completion: NULL];
}

@end
