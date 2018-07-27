//
//  UIViewController+NavButtons.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 23/09/15.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "UIViewController+NavButtons.h"

@implementation UIViewController (NavButtons)

- (UIBarButtonItem*) barButtonItem: (AINavigationButtonItemType) aButtonItemType
                            action: (SEL) aSelector
{
    UIBarButtonItem* barButtonItem = nil;
    NSString* title = nil;
    UIImage* image = nil;
    
    switch (aButtonItemType) {
        case BackButtonItem:
            title = NSLocalizedString(@"Back", nil);
            break;
            
        case ApplyButtonItem:
            title = NSLocalizedString(@"Apply", nil);
            break;

        case DoneButtonItem:
            title = NSLocalizedString(@"Done", nil);
            break;

        case AddButtonItem:
            title = NSLocalizedString(@"Add", nil);
            break;
            
        case EditButtonItem:
            title = NSLocalizedString(@"Edit", nil);
            break;

        case RemoveButtonItem:
            title = NSLocalizedString(@"Remove", nil);
            break;
            
        case CategoryButtonItem:
            title = NSLocalizedString(@"Category", nil);
            break;
            
        case MenuButtonItem:
            image = [UIImage imageNamed: @"menu"];
            break;
            
        default:
            NSAssert(NO, @"Bar button type is invalid!");
            break;
    }
    
    if (title)
    {
        barButtonItem = [[UIBarButtonItem alloc] initWithTitle: title
                                                         style: UIBarButtonItemStylePlain
                                                        target: self
                                                        action: aSelector];
    }
    else
    {
        barButtonItem = [[UIBarButtonItem alloc] initWithImage: image
                                                         style: UIBarButtonItemStylePlain
                                                        target: self
                                                        action: aSelector];
    }
    barButtonItem.tintColor = [UIColor whiteColor];
    UIFont* fontButton = [AIPreferences fontNormalWithSize: 17.0f];
    [barButtonItem setTitleTextAttributes: @{NSFontAttributeName: fontButton}
                                 forState: UIControlStateNormal];

    return barButtonItem;
}

- (UIBarButtonItem*) setLeftBarButtonItemType: (AINavigationButtonItemType) aButtonItemType
                                       action: (SEL) aSelector
{
    UIBarButtonItem* barButtonItem = [self barButtonItem: aButtonItemType
                                                  action: aSelector];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    return barButtonItem;
}


- (UIBarButtonItem*) setRightBarButtonItemType: (AINavigationButtonItemType) aButtonItemType
                                        action: (SEL) aSelector
{
    UIBarButtonItem* barButtonItem = [self barButtonItem: aButtonItemType
                                                  action: aSelector];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    return barButtonItem;
}

@end
