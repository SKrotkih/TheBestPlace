//
//  AIPlaceHolderTextView.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/23/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString* placeholder;
@property (nonatomic, retain) UIColor* placeholderColor;

- (void) textChanged: (NSNotification*) notification;

- (void) shake;

@end
