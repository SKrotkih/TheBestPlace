//
//  AIFeedbackBaseViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFeedbackBaseViewController.h"
#import "UIViewController+NavButtons.h"

@implementation AIFeedbackBaseViewController

- (void) savePhoto: (UIImage*) aPhotoImage
       resultBlock: (void (^)(NSError*)) aResultBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.feedback savePhoto: aPhotoImage
                     resultBlock: ^(NSError* error)
         {
             aResultBlock(error);
         }];
    });
}

#pragma mark Enable only Portrait mode

-(BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -

@end
