//
//  AIApplicationCloudProxy.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/13/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "User.h"
#import "AIUser.h"

@class AIFeedback, AIVote;

#define MRLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])

@interface AIApplicationCloudProxy : NSObject

- (void) facebookSignupWithUserInfo: (NSDictionary*) user
                       resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock;

- (void) loginUserWithEmail: (NSString*) email
                   password: (NSString*) password
                resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock;

- (void) signUpUserWithEmail: (NSString*) email
                    password: (NSString*) password
                    userName: (NSString*) userName
                      mobile: (NSString*) mobile
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

- (void) passwordUserWithID: (NSString*) userID
                resultBlock: (void (^)(NSString* aUserPassword, NSError* error)) aResultBlock;

- (void) fetchFeedbacksForVenueID: (NSString*) aVenueId
                      resultBlock: (void (^)(NSArray* aFeedbacks, NSArray* aLikes, NSArray* aDisLikes, NSArray* aLikeUsers, NSArray* aDisLikeUsers, NSError* error)) aResultBlock;

- (void) removeFeedbackWithId: (NSString*) aFeedbackid
                photoFileName: (NSString*) aPhotoFileName
                  resultBlock: (void (^)(id responseObject, NSError *error)) aResultBlock;

- (void) insertFeedback: (AIFeedback*) aFeedback
            resultBlock: (void (^)(id responseObject, NSError *error)) aResultBlock;

- (void) updateFeedback: (AIFeedback*) aFeedback
            resultBlock: (void (^)(id responseObject, NSError *error)) aResultBlock;

- (void) addVote: (AIVote*) aVote
     resultBlock: (void (^)(NSError *error)) aResultBlock;

- (void) fetchVote: (AIVote*) aVote
       resultBlock: (void (^)(id responseObject, NSError *error)) aResultBlock;

- (void) fetrchFeedbacksFeedForUserID: (NSString*) anUserId
                        friendsIdList: (NSString*) anUsersList
                          resultBlock: (void (^)(NSArray* aFeedbacks, NSArray* votes, NSError* error)) aResultBlock;

- (void) fetchUsersWithResultBlock: (void (^)(id responseObject, NSError *error)) aResultBlock;

- (void) addFriendWithID: (NSString*) aFriendID
               forUserId: (NSString*) aUserID
             resultBlock: (void (^)(NSError *error)) aResultBlock;

- (void) removeFriendWithID: aFriendID
                  forUserId: (NSString*) aUserID
                resultBlock: (void (^)(NSError *error)) aResultBlock;

- (void) fetchFriendsForUserID: (NSString*) aUserId
                   resultBlock: (void (^)(id responseObject, NSError *error)) aResultBlock;

- (void) saveNotesWithResultBlock: (void (^)(id responseObject, NSError *error)) aResultBlock;

- (void) removeDataFileName: (NSString*) aFileName
                resultBlock: (void (^)(NSError *error)) aResultBlock;

- (void) loginUserWithEmail2: (NSString*) email
                    password: (NSString*) password
                 resultBlock: (void (^)(NSError* anError, NSString* anUserID, NSString* aToken)) aResultBlock;

- (NSURL*) photoURLWithFileName: (NSString*) aDataFileName;

- (NSString*) imagesStorageFolder;

- (NSString*) URLforPingingToApplicationServer;

- (void) uploadDataAsFileName: (NSString*) aFullFileName
                  resultBlock: (void (^)(NSError*, NSString*)) aResultBlock;

@end
