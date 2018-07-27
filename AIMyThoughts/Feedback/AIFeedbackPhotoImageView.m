//
//  AIFeedbackPhotoImageView.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/28/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFeedbackPhotoImageView.h"
#import "AIFeedbackPhotoViewController.h"

@interface AIFeedbackPhotoImageView()
@property(nonatomic, strong) AIFeedbackPhotoViewController* feedbackPhotoViewController;
@end

@implementation AIFeedbackPhotoImageView
{

}

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame:frame]))
    {
    }

    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) touchesEnded: (NSSet*) touches
            withEvent: (UIEvent *)event
{
    UIImage* img = self.image;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath: self.imageFileName];
    
    if (img && isFileExists)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                             bundle: nil];
        self.feedbackPhotoViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIFeedbackPhotoVC"];
        self.feedbackPhotoViewController.photoImage = self.image;
        self.feedbackPhotoViewController.delegate = self.delegate;
        self.feedbackPhotoViewController.isEditable = self.isEditable;
        [self.parentViewController.navigationController pushViewController: self.feedbackPhotoViewController
                                                                  animated: YES];
    }
}

@end
