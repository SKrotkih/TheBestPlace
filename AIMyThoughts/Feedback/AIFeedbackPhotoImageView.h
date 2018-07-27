//
//  AIFeedbackPhotoImageView.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/28/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIFeedbackPhotoViewControllerDelegate.h"

@interface AIFeedbackPhotoImageView : UIImageView

@property(nonatomic, weak) IBOutlet UIViewController* parentViewController;
@property(nonatomic, weak) IBOutlet id<AIFeedbackPhotoViewControllerDelegate> delegate;
@property (nonatomic, weak) NSString* imageFileName;
@property(nonatomic, assign) BOOL isEditable;

@end
