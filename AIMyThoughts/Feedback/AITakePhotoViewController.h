//
//  AITakePhotoViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/27/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AITakeFotoControllerDelegate <NSObject>

- (void) done;
- (void) takePhoto;

@end

@interface AITakePhotoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
             delegate: (id<AITakeFotoControllerDelegate>) aDelegate;

@property(nonatomic, weak) id<AITakeFotoControllerDelegate> delelgate;

@property (nonatomic, weak) IBOutlet UIView* contentView;
@property (nonatomic, weak) IBOutlet UIToolbar* toolBar;

- (IBAction) doneButtonPressed: (id) sender;
- (IBAction) takePhotoButtonPressed: (id) sender;

@end
