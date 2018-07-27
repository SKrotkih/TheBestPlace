//
//  AIPhotoMakerController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/8/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AISavePhotoDelegate <NSObject>
- (void) savePhoto: (UIImage*) aPhotoImage;
@end

@interface AIPhotoMakerController : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImage* photoImage;

- (id) initWithViewController: (UIViewController*) aParentViewController
                     delegate: (id<AISavePhotoDelegate>) aDelegate;
- (void) showImagePickerForPhotoPicker;
- (void) showImagePickerForCamera;

@end
