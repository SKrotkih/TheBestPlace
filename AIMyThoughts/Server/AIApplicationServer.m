//
//  AIApplicationServer.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/13/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIApplicationServer.h"
#import "AIUser.h"
#import "AIApplicationCloudProxy.h"
#import "AILocalDataBase.h"

@interface AIApplicationServer()
@property(nonatomic, strong) AIApplicationCloudProxy* server;
@end

@implementation AIApplicationServer
{
    dispatch_queue_t _downloadFileQueue;
}

+ (AIApplicationServer*) sharedInstance
{
    static AIApplicationServer* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[AIApplicationServer alloc] init];
    });
    
    return instance;
}

- (id) init
{
    if ((self = [super init]))
    {
        self.server = [[AIApplicationCloudProxy alloc] init];
        dispatch_queue_t bgPriQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        _downloadFileQueue = dispatch_queue_create("DownloadingFilesQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_downloadFileQueue, bgPriQueue);
    }

    return  self;
}

#pragma mark Friends

- (void) addFriendWithID: (NSString*) aFriendID
                  forUserId: (NSString*) aUserID
                resultBlock: (void(^)(NSError* error)) aResultBlock
{
    [self.server addFriendWithID: aFriendID
                          forUserId: aUserID
                        resultBlock: aResultBlock];
}

- (void) removeFriendWithID: (NSString*) aFriendID
                  forUserId: (NSString*) anUserId
                resultBlock: (void (^)(NSError *error)) aResultBlock
{
    [self.server removeFriendWithID: aFriendID
                          forUserId: anUserId
                        resultBlock: aResultBlock];
}

- (void) fetchFriendsForUserID: (NSString*) aUserId
                   resultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aResultBlock
{
    [self.server fetchFriendsForUserID: aUserId
                           resultBlock: aResultBlock];
}

#pragma mark Users

- (void) getUserIdWithResultBlock: (void(^)(NSString* aUserId)) aUserIdCallback
{
    AIUser* currentUser = [AIUser currentUser];
    NSString* userId = nil;
    
    if (currentUser)
    {
        if (currentUser.userid)
        {
            userId = currentUser.userid;
        }
        else if (currentUser.fb_id)
        {
            userId = currentUser.fb_id;
        }
    }
    
    aUserIdCallback(userId);
}

- (void) fetchUsersWithResultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aResultBlock
{
    [self.server fetchUsersWithResultBlock: aResultBlock];
}

#pragma mark Fetch of the Feedbacks

- (void) saveNotesWithResultBlock: (void(^)(NSData* aNotes, NSError* error)) aResultBlock
{
    [self.server saveNotesWithResultBlock: aResultBlock];
}

- (void) fetrchFeedbacksFeedForUserID: (NSString*) aUserId
                        friendsIdList: (NSString*) anUsersList
                          resultBlock: (void(^)(NSArray* aFeedbacks, NSArray* votes, NSError* error)) aResultBlock
{
    [self.server fetrchFeedbacksFeedForUserID: aUserId
                                friendsIdList: anUsersList
                                  resultBlock: aResultBlock];
}

- (void) fetchFeedbacksForVenueID: (NSString*) aVenueId
                      resultBlock: (void(^)(NSArray* aFeedbacks, NSArray* aLikes, NSArray* aDisLikes, NSArray* aLikeUsers, NSArray* aDisLikeUsers, NSError* error)) aResultBlock
{
    [self.server fetchFeedbacksForVenueID: aVenueId
                              resultBlock: aResultBlock];
}

#pragma mark Delete Feedback

- (void) removeFeedback: (AIFeedback*) aFeedback
            resultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aResultBlock
{
    NSString* imageFileName = aFeedback.photo_suffix;
    
    [self.server removeFeedbackWithId: aFeedback.feedbackid
                        photoFileName: imageFileName
                          resultBlock: aResultBlock];
}

- (void) removePhoto: (NSString*) aDataFileName
         resultBlock: (void (^)(NSError* anError)) aResultBlock
{
    [self.server removeDataFileName: aDataFileName
                        resultBlock: aResultBlock];
}

#pragma mark Insert Feedback

- (void) insertFeedback: (AIFeedback*) aFeedback
            resultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aResultBlock
{
    [self.server insertFeedback: aFeedback
                    resultBlock: aResultBlock];
}

#pragma mark Update Feedback

- (void) updateFeedback: (AIFeedback*) aFeedback
            resultBlock: (void(^)(NSArray* aFeedbacks, NSError* error)) aResultBlock
{
    [self.server updateFeedback: aFeedback
                    resultBlock: aResultBlock];
}

#pragma mark Votes for Feedbacks

- (void) addVote: (AIVote*) aVote
     resultBlock: (void(^)(NSError* error)) aResultBlock
{
    [self.server addVote: aVote
             resultBlock: aResultBlock];
}

- (void) fetchVote: (AIVote*) aVote
       resultBlock: (void(^)(NSDictionary* dict, NSError* error)) aResultBlock
{
    [self.server fetchVote: aVote
               resultBlock: aResultBlock];
}

#pragma mark Log In

- (void) facebookSignupWithUserInfo: (NSDictionary*) aUserInfo
                       resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock
{
    [self.server facebookSignupWithUserInfo: aUserInfo
                               resultBlock: aResultBlock];
}

- (void) signUpUserWithEmail: (NSString*) email
                    password: (NSString*) password
                    userName: (NSString*) userName
                      mobile: (NSString*) mobile
                 resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock
{
    [self.server signUpUserWithEmail: email
                            password: password
                            userName: userName
                              mobile: mobile
                         resultBlock: aResultBlock];
}

- (void) loginUserWithEmail: (NSString*) email
                   password: (NSString*) password
                resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock
{
    [self.server loginUserWithEmail: email
                           password: password
                        resultBlock: aResultBlock];
}

- (void) resetPasswordUserWithEmail: (NSString*) anEmail
                        resultBlock: (void (^)(NSError* anError, NSString* anPassword)) aResultBlock
{
    [self.server resetPasswordUserWithEmail: anEmail
                                resultBlock: aResultBlock];
    
}

- (void) resetPasswordUserWithEmail: (NSString*) anEmail
                            to_name: (NSString*) anUserName
                            subject: (NSString*) aSubject
                            message: (NSString*) aMessage
                        resultBlock: (void (^)(NSError *error)) aResultBlock
{
    [self.server resetPasswordUserWithEmail: anEmail
                                    to_name: anUserName
                                    subject: aSubject
                                    message: aMessage
                                resultBlock: aResultBlock];
}

- (void) changePasswordUserWithID: (NSString*) userID
                      newPassword: (NSString*) password
                      resultBlock: (void (^)(NSError* error)) aResultBlock
{
    [self.server changePasswordUserWithID: userID
                              newPassword: password
                              resultBlock: aResultBlock];
    
}

- (void) loginUserWithEmail2: (NSString*) email
                    password: (NSString*) password
                 resultBlock: (void (^)(NSError* anError, id anUser, NSString* aToken)) aResultBlock
{
    [self.server loginUserWithEmail2: email
                            password: password
                         resultBlock: ^(NSError* anError, NSString* anUserID, NSString* aToken)
    {
        AIUser* user = nil;

        if (anUserID)
        {
            user = [[AILocalDataBase sharedInstance] userWithID: anUserID];
        }
        
        aResultBlock(anError, user, aToken);
    }];
    
}

- (void) passwordUserWithID: (NSString*) userID
                resultBlock: (void (^)(NSString* aUserPassword, NSError* error)) aResultBlock
{
    [self.server passwordUserWithID: userID
                        resultBlock: aResultBlock];
}

#pragma mark - Download Data

- (void) downloadDataFileName: (NSString*) aDataFileName
                 destFullPath: (NSString*) aDestFullPath
                  resultBlock: (void(^)(NSError*)) aResultBlock
{
    dispatch_async(_downloadFileQueue, ^{
        NSURL* photoURL = [self photoURLWithFileName: aDataFileName];
        NSData* theData = [NSData dataWithContentsOfURL: photoURL];
        NSError* error = nil;
        
        if (theData)
        {
            if (![theData writeToFile: aDestFullPath
                           atomically: YES])
            {
                NSLog(@"Failed to save file: %@", aDestFullPath);
            }
        }
        else
        {
            NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Failed download image from the app server!", nil)};
            error = [NSError errorWithDomain: kTheMainErrorsDomain
                                        code: -1
                                    userInfo: userInfo];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            aResultBlock(error);
        });
    });
}

- (NSURL*) photoURLWithFileName: (NSString*) aDataFileName
{
    return [self.server photoURLWithFileName: aDataFileName];
}

- (NSString*) imagesStorageFolder
{
    return [self.server imagesStorageFolder];
}

- (NSString*) URLforPingingToApplicationServer
{
    return [self.server URLforPingingToApplicationServer];
}

#pragma mark - Upload Data

- (void) uploadDataAsFileName: (NSString*) aFullFileName
                  resultBlock: (void (^)(NSError*, NSString*)) aResultBlock
{
    [self.server uploadDataAsFileName: (NSString*) aFullFileName
                          resultBlock: aResultBlock];
}

@end
