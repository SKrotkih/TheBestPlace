//
//  AICompanyProfileViewController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 3/28/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVenue.h"
#import "AIFeedback.h"

@class AICompanyProfileTableViewCell;

@protocol PressOnLikeDislikeDelegate  <NSObject>

- (void) likeButtonPressed: (AICompanyProfileTableViewCell*) aCell;
- (void) disLikeButtonPressed: (AICompanyProfileTableViewCell*) aCell;

@end

@interface AICompanyProfileViewController : UIViewController <PressOnLikeDislikeDelegate>

@property(nonatomic, strong) FSVenue* venue;
@property (nonatomic, weak) NSArray* allMyFiends;

@end
