//
//  UIViewController+NavButtons.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 23/09/15.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    BackButtonItem,
    ApplyButtonItem,
    DoneButtonItem,
    EditButtonItem,
    RemoveButtonItem,
    AddButtonItem,
    CategoryButtonItem,
    MenuButtonItem
} AINavigationButtonItemType;

@interface UIViewController (NavButtons)

- (UIBarButtonItem*) setLeftBarButtonItemType: (AINavigationButtonItemType) aButtonItem
                                   action: (SEL) aSelector;

- (UIBarButtonItem*) setRightBarButtonItemType: (AINavigationButtonItemType) aButtonItem
                                    action: (SEL) aSelector;

@end
