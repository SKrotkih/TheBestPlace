//
//  AILogInManager.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 9/5/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import "AILogInManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Utils.h"
#import "AIApplicationServer.h"
#import "MBProgressHUD.h"
#import "NSString+Validator.h"
#import "User.h"
#import "AILocalDataBase.h"
#import "AINetworkMonitor.h"

@interface AILogInManager() <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, copy) void(^resultBlock)();

@end

@implementation AILogInManager
{
    BOOL _facebookIsLoggedIn;
}

+ (AILogInManager*) sharedInstance
{
    static AILogInManager* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[AILogInManager alloc] init];
    });
    
    return instance;
}

#pragma mark Sign Up by Email

- (void) signUpWithUserId: (NSString*) anUserId
                 password: (NSString*) aPassword
                 userName: (NSString*) aUserName
                   mobile: (NSString*) aStrippedNumber
           viewControoler: (UIViewController*) aViewController
              resultBlock: (void(^)(AILoginState aLoginState)) aResultBlock
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        aResultBlock(InternetIsNotPresented);
        
        return;
    }
    
    if (![aUserName validateNonEmpty])
    {
        aResultBlock(UserNameIsWrong);
        
        return;
    }
    
    if (![anUserId validateEmail] || ![anUserId validateNonEmpty])
    {
        aResultBlock(UserIdIsWrong);
        
        return;
    }
    
    if (![aPassword validateNonEmpty])
    {
        aResultBlock(PasswordIsWrong);
        
        return;
    }
    [self signUpWithUserId: anUserId
                  password: aPassword
                  userName: aUserName
                    mobile: aStrippedNumber
               resultBlock: ^(NSError* anError, AIUser* anUser)
     {
         
         if (anError)
         {
             [AIAlertView showAlertWythViewController: aViewController
                                                title: NSLocalizedString(@"Error", nil)
                                                 text: [anError localizedDescription]];
             aResultBlock(FailedToRunLogIn);
             
             return;
         }
         NSString* userId = anUser.userid;
         AIUser* currentUser = [[AILocalDataBase sharedInstance] userWithID: userId];
         
         if (currentUser == nil)
         {
             anUser.currentUser = YES;
             [[AILocalDataBase sharedInstance] addUser: anUser];
         }
         else
         {
             NSAssert(NO, @"This user already exists in the database!");
         }
         _facebookIsLoggedIn = NO;
         [[NSNotificationCenter defaultCenter] postNotificationName: kSignInStateDidChangedNotification
                                                             object: nil];
         aResultBlock(OperationHasBeenFinishedSuccessfully);
     }];
}

- (void) signUpWithUserId: (NSString*) anUserId
                 password: (NSString*) aPassword
                 userName: (NSString*) aUserName
                   mobile: (NSString*) aStrippedNumber
              resultBlock: (void(^)(NSError* anError, AIUser* anUser)) aResultBlock
{
    [[AIApplicationServer sharedInstance] signUpUserWithEmail: anUserId
                                                     password: aPassword
                                                     userName: aUserName
                                                       mobile: aStrippedNumber
                                                  resultBlock: aResultBlock];
}

#pragma mark - Log In by Email

- (void) logInWithUserId: (NSString*) anUserId
                password: (NSString*) aPassword
          viewControoler: (UIViewController*) aViewController
             resultBlock: (void(^)(AILoginState aLoginState)) aResultBlock
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        aResultBlock(InternetIsNotPresented);
        
        return;
    }
    
    if (![anUserId validateEmail] || ![anUserId validateNonEmpty])
    {
        aResultBlock(UserIdIsWrong);
        
        return;
    }
    
    if (![aPassword validateNonEmpty])
    {
        aResultBlock(PasswordIsWrong);
        
        return;
    }
    [self userInfoWithUserId: anUserId
                    password: aPassword
                 resultBlock: ^(NSError* anError, AIUser* anUser)
     {
         
         if (anError)
         {
             if (anError.code == -2)
             {
                 aResultBlock(PasswordIsWrong);
             }
             else
             {
                 [AIAlertView showAlertWythViewController: aViewController
                                                    title: NSLocalizedString(@"Error", nil)
                                                     text: [anError localizedDescription]];
                 aResultBlock(FailedToRunLogIn);
             }
             
             return;
         }
         NSString* userId = anUser.userid;
         AIUser* currentUser = [[AILocalDataBase sharedInstance] userWithID: userId];
         
         if (currentUser == nil)
         {
             anUser.currentUser = YES;
             [[AILocalDataBase sharedInstance] addUser: anUser];
         }
         else
         {
             currentUser.currentUser = YES;
             [[AILocalDataBase sharedInstance] updateUserWithId: userId
                                                        forUser: currentUser];
         }
         _facebookIsLoggedIn = NO;
         [[NSNotificationCenter defaultCenter] postNotificationName: kSignInStateDidChangedNotification
                                                             object: nil];
         aResultBlock(OperationHasBeenFinishedSuccessfully);
     }];
}

- (void) userInfoWithUserId: (NSString*) anUserId
                   password: (NSString*) aPassword
                resultBlock: (void(^)(NSError* anError, AIUser* anUser)) aResultBlock
{
    [[AIApplicationServer sharedInstance] loginUserWithEmail: anUserId
                                                    password: aPassword
                                                 resultBlock: aResultBlock];
}

- (NSError*) internalError
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Internal error", nil)
                                                         forKey: NSLocalizedFailureReasonErrorKey];
    NSError* error = [[NSError alloc] initWithDomain: NSNetServicesErrorDomain
                                                code: -1
                                            userInfo: userInfo];
    return error;
}


#pragma mark Forget Password

- (void) getPasswordForEmail: (NSString*) anEmail
                 resultBlock: (void(^)(NSError* anError, NSString* anPassword)) aResultBlock
{
    [[AIApplicationServer sharedInstance] resetPasswordUserWithEmail: anEmail
                                                         resultBlock: aResultBlock];
}

- (void) sendPasswordOnEmail: (NSString*) email
                    userName: (NSString* ) userName
                     subject: (NSString*) subject
             messageTemplate: (NSString*) messageTemplate
                 resultBlock: (void(^)(NSError* anError)) aResultBlock
{
    [[AIApplicationServer sharedInstance] resetPasswordUserWithEmail: email
                                                             to_name: userName
                                                             subject: subject
                                                             message: messageTemplate
                                                         resultBlock: aResultBlock];
}

- (void) resetPasswordForUserId: (NSString*) aUserId
                       password: (NSString*) aPassword
                    resultBlock: (void(^)(NSError* anError)) aResultBlock
{
    [[AIApplicationServer sharedInstance] changePasswordUserWithID: aUserId
                                                       newPassword: aPassword
                                                       resultBlock: aResultBlock];
}

- (void) sendResetPasswordForUserId: (NSString*) anUserId
                           password: (NSString*) aPassword
                        resultBlock: (void(^)(NSError* anError, id anUser, NSString* aToken)) aResultBlock
{
    [[AIApplicationServer sharedInstance] loginUserWithEmail2: anUserId
                                                     password: aPassword
                                                  resultBlock: aResultBlock];
}

#pragma mark - Log In by Facebook

- (void) logInWithFacebookWithViewControoler: (UIViewController*) aViewController
                                 resultBlock: (void(^)(AILoginState aLoginState)) aResultBlock
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        aResultBlock(InternetIsNotPresented);
        
        return;
    }
    FBSDKLoginManager* login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
                 fromViewController: aViewController
                            handler: ^(FBSDKLoginManagerLoginResult* result, NSError* error)
     {
         if (error)
         {
             NSString* message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?: @"There was a problem logging in, please try again later.";
             NSString* title = error.userInfo[FBSDKErrorLocalizedTitleKey] ? : @"Oops!";
             [AIAlertView showAlertWythViewController: aViewController
                                                title: title
                                                 text: message];
             aResultBlock(FailedToRunLogIn);
         }
         else if (result.isCancelled)
         {
             aResultBlock(LogInCancelled);
         }
         else
         {
             [self facebookUserInfoWithResultBlock: ^(NSError* anError, AIUser* anUser){
                 
                 if (anError)
                 {
                     [AIAlertView showAlertWythViewController: aViewController
                                                        title: NSLocalizedString(@"Error", nil)
                                                         text: [anError localizedDescription]];
                     aResultBlock(FailedToRunLogIn);
                     
                     return;
                 }
                 NSString* fbUserId = anUser.fb_id;
                 AIUser* currentUser = [[AILocalDataBase sharedInstance] userWithFbId: fbUserId];
                 
                 if (currentUser == nil)
                 {
                     anUser.currentUser = YES;
                     [[AILocalDataBase sharedInstance] addUser: anUser];
                 }
                 else
                 {
                     currentUser.currentUser = YES;
                     [[AILocalDataBase sharedInstance] updateUserWithFbId: fbUserId
                                                                  forUser: currentUser];
                 }
                 _facebookIsLoggedIn = YES;
                 [[NSNotificationCenter defaultCenter] postNotificationName: kSignInStateDidChangedNotification
                                                                     object: nil];
                 aResultBlock(OperationHasBeenFinishedSuccessfully);
             }];
         }
     }];
}

- (void) facebookUserInfoWithResultBlock: (void(^)(NSError* anError, AIUser* anUser)) aResultBlock
{
    if (![FBSDKAccessToken currentAccessToken])
    {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Internal Facebook connect error!", nil)
                                                             forKey: NSLocalizedFailureReasonErrorKey];
        NSError* error = [[NSError alloc] initWithDomain: NSNetServicesErrorDomain
                                                    code: -1
                                                userInfo: userInfo];
        aResultBlock(error, nil);
        
        return;
    }
    [MBProgressHUD startProgressWithAnimation: NO];
    
    NSDictionary* parameters = @{@"fields": @"picture,id,birthday,email,name,gender,first_name,last_name"};
    FBSDKGraphRequest* request = [[FBSDKGraphRequest alloc] initWithGraphPath: @"me"
                                                                   parameters: parameters];
    
    [request startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection, id result, NSError* error)
     {
         [MBProgressHUD stopProgressWithAnimation: NO];
         
         if (error)
         {
             aResultBlock(error, nil);
             
             return;
         }
         NSDictionary* user = result;
         [[AIApplicationServer sharedInstance] facebookSignupWithUserInfo: user
                                                              resultBlock: aResultBlock];
     }];
}

#pragma mark - Log Out

- (void) logOutWithSuccessBlock: (void(^)()) aResultBlock
{
    AIUser* currentUser = [AIUser currentUser];
    
    if (!currentUser)
    {
        return;
    }
    
    currentUser.currentUser = NO;
    
    if (_facebookIsLoggedIn)
    {
        FBSDKLoginManager* login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        
        [[AILocalDataBase sharedInstance] updateUserWithFbId: currentUser.fb_id
                                                     forUser: currentUser];
        
        _facebookIsLoggedIn = NO;
    }
    else
    {
        [[AILocalDataBase sharedInstance] updateUserWithId: currentUser.userid
                                                   forUser: currentUser];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kSignInStateDidChangedNotification
                                                        object: nil];
    
    aResultBlock();
    
}

- (void) logOutAlertWithViewController: (UIViewController*) aViewController
                           resultBlock: (void(^)()) aResultBlock
{
    AIUser* currentUser = [AIUser currentUser];
    
    if (currentUser)
    {
        self.resultBlock = aResultBlock;
        
        UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle: nil
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"Log Out", nil), nil];
        [sheet showInView: aViewController.view];
    }
}

- (void) willPresentActionSheet: (UIActionSheet*) actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock: ^(UIView* subview, NSUInteger idx, BOOL* stop)
     {
         if ([subview isKindOfClass: [UIButton class]])
         {
             UIButton* button = (UIButton*) subview;
             button.titleLabel.textColor = [Utils colorWithRGBHex: 0xFA6407];
         }
     }];
}

- (void) actionSheet: (UIActionSheet*) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 0)
    {
        [self logOutWithSuccessBlock:^{
            self.resultBlock();
        }];
    }
}

@end
