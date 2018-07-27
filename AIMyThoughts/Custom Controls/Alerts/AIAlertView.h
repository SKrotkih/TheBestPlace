//
//  AIAlertView.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 8/20/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIAlertView : NSObject

+ (void) showUIAlertWythTitle: (NSString*) aTitle
                         text: (NSString*) aMessage;

+ (void) showAlertWythViewController: (UIViewController*) aViewController
                               title: (NSString*) aTitle
                                text: (NSString*) aMessage;

+ (void) showAlertWythViewController: (UIViewController*) aViewController
                               title: (NSString*) aTitle
                                text: (NSString*) aMessage
                       okButtonBlock: (void(^)()) anOkBlock
                   cancelButtonBlock: (void(^)()) aCancelBlock;

+ (void) showAlertWythViewController: (UIViewController*) aViewController
                               title: (NSString*) aTitle
                                text: (NSString*) aMessage
              enterEmailAndNameBlock: (void(^)(NSString*, NSString*)) anOkBlock
                   cancelButtonBlock: (void(^)()) aCancelBlock;


@end
