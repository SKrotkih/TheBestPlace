//
//  AIFeedbackBaseViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/26/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIFeedback.h"

@interface AIFeedbackBaseViewController : UIViewController

@property (nonatomic, strong) AIFeedback* feedback;

- (void) savePhoto: (UIImage*) aPhotoImage
        resultBlock: (void (^)(NSError*)) aResultBlock;

@end
