//
//  AIFeedbackViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIFeedbackBaseViewController.h"
#import "FSVenue.h"
#import "AIPhotoMakerController.h"
#import "AIFeedbackPhotoViewControllerDelegate.h"

@interface AIFeedbackViewController : AIFeedbackBaseViewController <AISavePhotoDelegate, AIFeedbackPhotoViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, assign) BOOL isItNewFeedback;
@property(nonatomic, strong) FSVenue* venue;
@property(nonatomic, copy) NSString* venueName;
@property(nonatomic, weak) NSMutableArray* feedbacks;

@end
