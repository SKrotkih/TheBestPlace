//
//  AIApplicationServer.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/13/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIFeedback.h"
#import "AIVote.h"
#import "AIUser.h"

@interface AIApplicationServer : NSObject

+ (AIApplicationServer*) sharedInstance;

- (void) getUserIdWithResultBlock: (void(^)(NSString* aUserId)) aUserIdCallback;

#pragma mark Friends

- (void) addFriendWithID: (NSString*) aFriendID
                  forUserId: (NSString*) aUserID
                resultBlock: (void(^)(NSError* error)) aFeedbacksCallback;

- (void) fetchFriendsForUserID: (NSString*) aUserId
                   resultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aResultBlock;

- (void) removeFriendWithID: (NSString*) aFriendID
                  forUserId: (NSString*) anUserId
                resultBlock: (void (^)(NSError *error)) aResultBlock;

#pragma mark Feedbacks

- (void) fetrchFeedbacksFeedForUserID: (NSString*) aUserId
                        friendsIdList: (NSString*) anUsersList
                          resultBlock: (void(^)(NSArray* aFeedbacks, NSArray* votes, NSError* error)) aResultBlock;

- (void) fetchUsersWithResultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aResultBlock;


- (void) fetchFeedbacksForVenueID: (NSString*) aVenueId
                      resultBlock: (void(^)(NSArray* aFeedbacks, NSArray* aLikes, NSArray* aDisLikes, NSArray* aLikeUsers, NSArray* aDisLikeUsers, NSError* error)) aResultBlock;

- (void) insertFeedback: (AIFeedback*) aFeedback
            resultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aFeedbacksCallback;

- (void) updateFeedback: (AIFeedback*) aFeedback
            resultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aFeedbacksCallback;

- (void) removeFeedback: (AIFeedback*) aFeedback
            resultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aFeedbacksCallback;

#pragma mark Votes

- (void) addVote: (AIVote*) aVote
     resultBlock: (void(^)(NSError* error)) aResultBlock;

- (void) fetchVote: (AIVote*) aVote
        resultBlock: (void(^)(NSDictionary* dict, NSError* error)) aResultBlock;

- (void) saveNotesWithResultBlock: (void(^)(NSData* aNotes, NSError* error)) aNotesCallback;

- (void) removePhoto: (NSString*) aDataFileName
         resultBlock: (void (^)(NSError* anError)) aCallBack;


- (void) facebookSignupWithUserInfo: (NSDictionary*) aUserInfo
                       resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock;

- (void) signUpUserWithEmail: (NSString*) email
                    password: (NSString*) password
                    userName: (NSString*) userName
                      mobile: (NSString*) mobile
                 resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock;

- (void) loginUserWithEmail: (NSString*) email
                   password: (NSString*) password
                resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock;

- (void) resetPasswordUserWithEmail: (NSString*) anEmail
                        resultBlock: (void (^)(NSError* anError, NSString* anPassword)) aResultBlock;


- (void) resetPasswordUserWithEmail: (NSString*) anEmail
                            to_name: (NSString*) anUserName
                            subject: (NSString*) aSubject
                            message: (NSString*) aMessage
                        resultBlock: (void (^)(NSError *error)) aResultBlock;

- (void) changePasswordUserWithID: (NSString*) userID
                      newPassword: (NSString*) password
                      resultBlock: (void (^)(NSError* error)) aResultBlock;


- (void) loginUserWithEmail2: (NSString*) email
                    password: (NSString*) password
                 resultBlock: (void (^)(NSError* anError, id anUser, NSString* aToken)) aResultBlock;

- (void) passwordUserWithID: (NSString*) userID
                resultBlock: (void (^)(NSString* aUserPassword, NSError* error)) aResultBlock;

- (void) downloadDataFileName: (NSString*) aDataFileName
                 destFullPath: (NSString*) aDestFullPath
                  resultBlock: (void(^)(NSError*)) aResultBlock;

- (NSURL*) photoURLWithFileName: (NSString*) aDataFileName;

- (NSString*) imagesStorageFolder;

- (NSString*) URLforPingingToApplicationServer;

- (void) uploadDataAsFileName: (NSString*) aFullFileName
                  resultBlock: (void (^)(NSError*, NSString*)) aResultBlock;

@end
