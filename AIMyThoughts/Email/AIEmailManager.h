//
//  AIEmailManager.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 7/31/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIEmailManager : NSObject

+ (AIEmailManager*) sharedInstance;

- (void) sendEmailWithInviteWithEmail: (NSString*) anEmail
                           friendName: (NSString*) aFriendName;

- (void) sendInviteEmailTo: (NSString*) eMail
                      name: (NSString*) aName
            viewController: (UIViewController*) aViewController;

- (void) sendMailBySKPSMTPMessageWithEmail: (NSString*) toEmail
                                   to_name: (NSString*) anUserName
                                   subject: (NSString*) subject
                                   message: (NSString*) message
                             isMessageHTML: (BOOL) anIsMessageHTML
                               resultBlock: (void(^)(NSError*)) aResultBlock;


@end
