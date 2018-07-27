//
//  AIAlertView.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 8/20/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import "AIAlertView.h"

@implementation AIAlertView

+ (void) showUIAlertWythTitle: (NSString*) aTitle
                         text: (NSString*) aMessage
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: aTitle
                                                        message: aMessage
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                              otherButtonTitles: nil, nil];
    [alertView show];
}

+ (void) showAlertWythViewController: (UIViewController*) aViewController
                               title: (NSString*) aTitle
                                text: (NSString*) aMessage
{
    UIAlertController*  alert=   [UIAlertController alertControllerWithTitle: aTitle
                                                                     message: aMessage
                                                              preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction* action = [UIAlertAction  actionWithTitle: @"OK"
                                                      style: UIAlertActionStyleDefault
                                                    handler: ^(UIAlertAction * action)
    {
        [alert dismissViewControllerAnimated: YES
                                  completion: nil];
    }];
    [alert addAction: action];
    
    [aViewController presentViewController: alert
                                  animated: YES
                                completion: nil];
}

+ (void) showAlertWythViewController: (UIViewController*) aViewController
                               title: (NSString*) aTitle
                                text: (NSString*) aMessage
                       okButtonBlock: (void(^)()) anOkBlock
                   cancelButtonBlock: (void(^)()) aCancelBlock
{
    UIAlertController*  alert=   [UIAlertController alertControllerWithTitle: aTitle
                                                                     message: aMessage
                                                              preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* actionOk = [UIAlertAction  actionWithTitle: NSLocalizedString(@"OK", nil)
                                                  style: UIAlertActionStyleDefault
                                                handler: ^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated: YES
                                                       completion: nil];
                             anOkBlock();
                         }];
    [alert addAction: actionOk];

    if (aCancelBlock)
    {
        UIAlertAction* actionCancel = [UIAlertAction actionWithTitle: NSLocalizedString(@"Cancel", nil)
                                                               style: UIAlertActionStyleDefault
                                                             handler: ^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated: YES
                                                                     completion: nil];
                                           aCancelBlock();
                                       }];
        [alert addAction: actionCancel];
    }
    
    [aViewController presentViewController: alert
                                  animated: YES
                                completion: nil];
}

+ (void) showAlertWythViewController: (UIViewController*) aViewController
                               title: (NSString*) aTitle
                                text: (NSString*) aMessage
              enterEmailAndNameBlock: (void(^)(NSString*, NSString*)) anOkBlock
                   cancelButtonBlock: (void(^)()) aCancelBlock
{
    __block UITextField* emailTextField = nil;
    __block UITextField* nameTextField = nil;
    
    UIAlertController*  alert=   [UIAlertController alertControllerWithTitle: aTitle
                                                                     message: aMessage
                                                              preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* actionOk = [UIAlertAction  actionWithTitle: NSLocalizedString(@"OK", nil)
                                                        style: UIAlertActionStyleDefault
                                                      handler: ^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated: YES
                                                             completion: nil];
                                   anOkBlock(emailTextField.text, nameTextField.text);
                               }];
    [alert addAction: actionOk];
    
    if (aCancelBlock)
    {
        UIAlertAction* actionCancel = [UIAlertAction actionWithTitle: NSLocalizedString(@"Cancel", nil)
                                                               style: UIAlertActionStyleDefault
                                                             handler: ^(UIAlertAction * action)
                                       {
                                           [alert dismissViewControllerAnimated: YES
                                                                     completion: nil];
                                           aCancelBlock();
                                       }];
        [alert addAction: actionCancel];
    }
    
    [alert addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
        emailTextField = textField;
        emailTextField.placeholder = NSLocalizedString(@"email", nil);
        emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    }];

    [alert addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
        nameTextField = textField;
        nameTextField.placeholder = NSLocalizedString(@"name", nil);
    }];
    
    [aViewController presentViewController: alert
                                  animated: YES
                                completion: nil];
}

@end
