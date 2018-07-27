//
//  AILogInManager.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 9/5/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    UserIdIsWrong,
    UserNameIsWrong,
    PasswordIsWrong,
    InternetIsNotPresented,
    FailedToRunLogIn,
    OperationHasBeenFinishedSuccessfully,
    LogInCancelled
} AILoginState;

@interface AILogInManager : NSObject

+ (AILogInManager*) sharedInstance;

- (void) signUpWithUserId: (NSString*) anUserId
                 password: (NSString*) aPassword
                 userName: (NSString*) aUserName
                   mobile: (NSString*) aStrippedNumber
           viewControoler: (UIViewController*) aViewController
          resultBlock: (void(^)(AILoginState aLoginState)) aResultBlock;

- (void) logInWithUserId: (NSString*) anUserId
                password: (NSString*) aPassword
          viewControoler: (UIViewController*) aViewController
         resultBlock: (void(^)(AILoginState aLoginState)) aResultBlock;

- (void) logInWithFacebookWithViewControoler: (UIViewController*) aViewController
                             resultBlock: (void(^)(AILoginState aLoginState)) aResultBlock;

- (void) logOutWithSuccessBlock: (void(^)()) aResultBlock;
- (void) logOutAlertWithViewController: (UIViewController*) aViewController
                       resultBlock: (void(^)()) aResultBlock;

- (void) getPasswordForEmail: (NSString*) anEmail
             resultBlock: (void(^)(NSError* anError, NSString* anPassword)) aResultBlock;

- (void) sendPasswordOnEmail: (NSString*) email
                    userName: (NSString* ) userName
                     subject: (NSString*) subject
             messageTemplate: (NSString*) messageTemplate
             resultBlock: (void(^)(NSError* anError)) aResultBlock;

- (void) resetPasswordForUserId: (NSString*) aUserId
                       password: (NSString*) aPassword
                resultBlock: (void(^)(NSError* anError)) aResultBlock;

- (void) sendResetPasswordForUserId: (NSString*) anUserId
                           password: (NSString*) aPassword
                    resultBlock: (void(^)(NSError* anError, id anUser, NSString* aToken)) aResultBlock;


@end
