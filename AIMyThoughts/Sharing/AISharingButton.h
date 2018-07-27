//
//  AISharingButton.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 9/26/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

typedef enum : NSUInteger {
    Facebook,
    Twitter,
    Foursquare
} TypeSocialNework;

@interface AISharingButton : UIButton

@property(nonatomic) IBInspectable NSInteger typeOfSharing;
@property(nonatomic, weak) UITextField* shareTextField;
@property(nonatomic, weak) UITextView* shareTexView;
@property(nonatomic, weak) UIViewController* viewController;
@property(nonatomic, copy) NSString* venueId;
@property(nonatomic, copy) NSURL* photoURL;

@end
