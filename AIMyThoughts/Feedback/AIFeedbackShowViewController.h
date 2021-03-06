//
//  AIFeedbackShowViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIFeedbackPhotoViewControllerDelegate.h"
#import "AIFeedbackBaseViewController.h"
#import "FSVenue.h"
#import "AIPhotoMakerController.h"

@interface AIFeedbackShowViewController : AIFeedbackBaseViewController

@property(nonatomic, strong) FSVenue* venue;
@property(nonatomic, copy) NSString* venueName;

@end
