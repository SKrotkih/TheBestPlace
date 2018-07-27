//
//  AIFeedbackPhotoViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/28/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIFeedbackPhotoViewControllerDelegate.h"

@interface AIFeedbackPhotoViewController : UIViewController

@property (nonatomic, strong) UIImage* photoImage;
@property (nonatomic, weak) IBOutlet UIImageView* photoImaveView;
@property (nonatomic, weak) id<AIFeedbackPhotoViewControllerDelegate> delegate;
@property(nonatomic, assign) BOOL isEditable;

@end
