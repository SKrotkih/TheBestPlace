//
//  AIApplicationCloudProxy.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/13/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIApplicationCloudProxy.h"
#import "AIApplicationCloudManager.h"
#import "AINetworkMonitor.h"
#import "AIFeedback.h"
#import "AIVote.h"

// The Hosting Server http://54.68.100.24:10000
// NSString* const kCloudPingURL =            @"54.68.100.24";
// NSString* const kCloudRootFolderURL =     @"http://54.68.100.24/tb/";

NSString* const kCloudPingURL =          @"http://thebestplace.krizantos.com";
NSString* const kCloudRootFolderURL =    @"http://thebestplace.krizantos.com/";
NSString* const kCloudStorageFolderURL = @"http://thebestplace.krizantos.com/data";

@interface AIApplicationCloudProxy ()

@property (nonatomic, strong) AIApplicationCloudManager* cloudManager;

@end

@implementation AIApplicationCloudProxy

- (id) init
{
    if ((self = [super init]))
    {
        NSURL* baseURL = [NSURL URLWithString: kCloudRootFolderURL];
        self.cloudManager = [[AIApplicationCloudManager alloc] initWithBaseURL: baseURL];
    }
    
    return self;
}

#pragma mark - Singup

- (void) facebookSignupWithUserInfo: (NSDictionary*) user
                        resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock
{
    NSString* photo = [user valueForKeyPath: @"picture.data.url"];
    NSDictionary* parameters = @{@"username": user[@"name"], @"photo": photo, @"firstname": user[@"first_name"], @"lastname": user[@"last_name"], @"email" : [user valueForKey: @"email"], @"facebook_id": user[@"id"]};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"facebook_signup.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError, nil);
             
             return;
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 NSDictionary* userData = theResponseObject[@"user"];
                 AIUser* currentUser = [[AIUser alloc] initWithDict: userData];
                 aResultBlock(nil, currentUser);
             }
             else
             {
                 aResultBlock(self.internalError, nil);
             }
         }
         else
         {
             aResultBlock(self.internalError, nil);
         }
     }];
}

- (void) signUpUserWithEmail: (NSString*) anEmail
                    password: (NSString*) aPassword
                    userName: (NSString*) anUserName
                      mobile: (NSString*) aMobile
                 resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock
{
    NSDictionary* parameters = @{@"username": anUserName, @"email": anEmail, @"password" : aPassword, @"phone" : aMobile};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"signup.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError, nil);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 NSDictionary* user = theResponseObject[@"user"];
                 AIUser* currentUser = [[AIUser alloc] initWithDict: user];
                 aResultBlock(nil, currentUser);
             }
             else
             {
                 aResultBlock(self.internalError, nil);
             }
         }
         else
         {
             aResultBlock(self.internalError, nil);
         }
     }];
}

#pragma mark - Login

- (void) loginUserWithEmail: (NSString*) email
                   password: (NSString*) password
                resultBlock: (void (^)(NSError* anError, AIUser* anUser)) aResultBlock
{
    NSDictionary* parameters = @{@"email": email, @"password": password};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"signin.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError, nil);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 NSDictionary* user = theResponseObject[@"user"];
                 AIUser* currentUser = [[AIUser alloc] initWithDict: user];
                 aResultBlock(nil, currentUser);
             }
             else
             {
                 NSDictionary* userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Password is wrong!", nil)
                                                                      forKey: NSLocalizedFailureReasonErrorKey];
                 NSError* error = [[NSError alloc] initWithDomain: NSNetServicesErrorDomain
                                                             code: -2
                                                         userInfo: userInfo];
                 aResultBlock(error, nil);
             }
         }
         else
         {
             aResultBlock(self.internalError, nil);
         }
     }
     ];
}

- (void) loginUserWithEmail2: (NSString*) email
                    password: (NSString*) password
                 resultBlock: (void (^)(NSError* anError, NSString* anUserID, NSString* aToken)) aResultBlock
{
    NSDictionary* parameters = @{@"email": email, @"password": password};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"signin.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError, nil, nil);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* userid = [NSString stringWithFormat: @"%d", [[theResponseObject valueForKeyPath: @"result.user.id"] intValue]];
             NSString* token = [theResponseObject valueForKeyPath: @"result.token"];
             aResultBlock(nil, userid, token);
         }
         else
         {
             NSString* message = [theResponseObject valueForKey: @"message"];
             NSDictionary* userInfo = [NSDictionary dictionaryWithObject: message
                                                                  forKey: NSLocalizedFailureReasonErrorKey];
             NSError* error = [[NSError alloc] initWithDomain: NSNetServicesErrorDomain
                                                         code: -1
                                                     userInfo: userInfo];
             aResultBlock(error, nil, nil);
         }
     }];
}

#pragma mar Password Reset

- (void) resetPasswordUserWithEmail: (NSString*) anEmail
                        resultBlock: (void (^)(NSError* anError, NSString* anPassword)) aResultBlock
{
    NSDictionary* parameters = @{@"email": anEmail};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"resetpassword.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError, nil);
         }
         else if (theResponseObject)
         {
             if ([[theResponseObject objectForKey: @"status"] integerValue] == 1)
             {
                 if ([[theResponseObject objectForKey: @"result"] isEqualToString: @"YES"])
                 {
                     NSString* password = [theResponseObject objectForKey: @"password"];
                     aResultBlock(nil, password);
                 }
                 else
                 {
                     aResultBlock(self.internalError, nil);
                 }
             }
             else
             {
                 aResultBlock(self.internalError, nil);
             }
         }
     }];
}

- (void) resetPasswordUserWithEmail: (NSString*) anEmail
                            to_name: (NSString*) anUserName
                            subject: (NSString*) aSubject
                            message: (NSString*) aMessage
                        resultBlock: (void (^)(NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"email": anEmail, @"subject": aSubject, @"message": aMessage, @"name": anUserName};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"resetpassword.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError);
         }
         else if (theResponseObject)
         {
             if ([[theResponseObject objectForKey: @"status"] integerValue] == 1)
             {
                 aResultBlock(nil);
             }
             else
             {
                 aResultBlock(self.internalError);
             }
         }
     }];
}

#pragma mark New Password for User

- (void) changePasswordUserWithID: (NSString*) userID
                      newPassword: (NSString*) password
                      resultBlock: (void (^)(NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"userid": userID, @"password": password};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"newpassword.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError);
         }
         else if ([[theResponseObject objectForKey: @"status"] intValue] == 1)
         {
             aResultBlock(nil);
         }
         else
         {
             aResultBlock(self.internalError);
         }
     }];
}

#pragma mark Current User Password

- (void) passwordUserWithID: (NSString*) userID
                resultBlock: (void (^)(NSString* aUserPassword, NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"userid": userID};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"oldpassword.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 NSDictionary* userData = theResponseObject[@"0"];
                 NSString* userPassword = userData[@"password"];
                 aResultBlock(userPassword, nil);
             }
             else
             {
                 aResultBlock(nil, self.internalError);
             }
         }
     }];
}

#pragma mark - Friends

- (void) addFriendWithID: (NSString*) aFriendID
               forUserId: (NSString*) aUserID
             resultBlock: (void (^)(NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"userid": aUserID, @"friendid": aFriendID};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"addfriend.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 aResultBlock(nil);
             }
             else
             {
                 NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"He or She exists in your friends list already!", nil)};
                 
                 NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                                      code: -1
                                                  userInfo: userInfo];
                 aResultBlock(error);
             }
         }
         else
         {
             NSLog(@"addfriend.php: script error!");
             
             aResultBlock(self.internalError);
         }
     }];
}

- (void) removeFriendWithID: aFriendID
                  forUserId: (NSString*) aUserID
                resultBlock: (void (^)(NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"userid": aUserID, @"friendid": aFriendID};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"removefriend.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 aResultBlock(nil);
             }
             else
             {
                 NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Sorry, failed to remove data!", nil)};
                 
                 NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                                      code: -1
                                                  userInfo: userInfo];
                 
                 aResultBlock(error);
             }
         }
         else
         {
             NSLog(@"Error while launching of the friends.php script!");
             
             aResultBlock(self.internalError);
         }
     }];
}

- (void) fetchFriendsForUserID: (NSString*) aUserId
                   resultBlock: (void (^)(id responseObject, NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"userid": aUserId};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"friends.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 NSArray* data = (NSArray*) theResponseObject[@"data"];
                 NSMutableArray* users = [[NSMutableArray alloc] init];
                 
                 for (NSDictionary* dict in data)
                 {
                     AIUser* user = [[AIUser alloc] initWithDict: dict];
                     [users addObject: user];
                 }
                 
                 aResultBlock(users, nil);
             }
             else
             {
                 NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Failed to read friends list!", nil)};
                 
                 NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                                      code: -1
                                                  userInfo: userInfo];
                 
                 aResultBlock(nil, error);
             }
         }
         else
         {
             NSLog(@"Error while launching of the friends.php script!");
             
             aResultBlock(nil, self.internalError);
         }
     }];
}

#pragma mark - Users

- (void) fetchUsersWithResultBlock: (void (^)(id responseObject, NSError* error)) aResultBlock
{
    NSDictionary* parameters = nil;
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"select_users.php"
                                        resultBlock:  ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 NSArray* data = (NSArray*) theResponseObject[@"data"];
                 NSMutableArray* users = [[NSMutableArray alloc] init];
                 
                 for (NSDictionary* dict in data)
                 {
                     AIUser* user = [[AIUser alloc] initWithDict: dict];
                     [users addObject: user];
                 }
                 
                 aResultBlock(users, nil);
             }
             else
             {
                 aResultBlock(nil, self.internalError);
             }
         }
         else
         {
             NSLog(@"Error while launching of the select_users.php script!");
             
             aResultBlock(nil, self.internalError);
         }
     }];
}

#pragma mark - Feedbacks

- (void) saveNotesWithResultBlock: (void (^)(id aResponseObject, NSError* error)) aResultBlock
{
    NSDictionary* parameters = nil;
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"test.php"
                                        resultBlock:  ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, theError);
         }
         else
         {
             aResultBlock(theResponseObject, nil);
         }
     }];
}

- (void) fetchFeedbacksForVenueID: (NSString*) aVenueId
                      resultBlock: (void (^)(NSArray* aFeedbacks, NSArray* aLikes, NSArray* aDisLikes, NSArray* aLikeUsers, NSArray* aDisLikeUsers, NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"venueid": aVenueId};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"select_feedbacks.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, nil, nil, nil, nil, theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 NSArray* data = (NSArray*) theResponseObject[@"data"];
                 NSMutableArray* feedbacks = [[NSMutableArray alloc] init];
                 
                 for (NSDictionary* dict in data)
                 {
                     AIFeedback* feedback = [[AIFeedback alloc] initWithDict: dict];
                     [feedbacks addObject: feedback];
                 }
                 
                 NSArray* likeData = (NSArray*) theResponseObject[@"like"];
                 NSMutableArray* likes = [[NSMutableArray alloc] init];
                 
                 for (NSDictionary* dict in likeData)
                 {
                     [likes addObject: dict];
                 }
                 
                 NSArray* disLikeData = (NSArray*) theResponseObject[@"dislike"];
                 NSMutableArray* disLikes = [[NSMutableArray alloc] init];
                 
                 for (NSDictionary* dict in disLikeData)
                 {
                     [disLikes addObject: dict];
                 }
                 
                 NSArray* likeUsersData = (NSArray*) theResponseObject[@"likeusers"];
                 NSMutableArray* likeUsers = [[NSMutableArray alloc] init];
                 
                 for (NSDictionary* dict in likeUsersData)
                 {
                     [likeUsers addObject: dict];
                 }
                 
                 NSArray* disLikeUsersData = (NSArray*) theResponseObject[@"dislikeusers"];
                 NSMutableArray* disLikeUsers = [[NSMutableArray alloc] init];
                 
                 for (NSDictionary* dict in disLikeUsersData)
                 {
                     [disLikeUsers addObject: dict];
                 }
                 aResultBlock(feedbacks, likes, disLikes, likeUsers, disLikeUsers, nil);
             }
             else
             {
                 aResultBlock(nil, nil, nil, nil, nil, self.internalError);
             }
         }
         else
         {
             NSLog(@"Error while launching of the select_feedbacks.php script!");
             
             aResultBlock(nil, nil, nil, nil, nil, nil);
         }
     }];
}

- (void) removeFeedbackWithId: (NSString*) aFeedbackid
                photoFileName: (NSString*) aPhotoFileName
                  resultBlock: (void (^)(id responseObject, NSError* error)) aResultBlock
{
    NSString* photoFileName = aPhotoFileName == nil ? @"": aPhotoFileName;
    NSDictionary* parameters = @{@"feedbackid": aFeedbackid, @"file": photoFileName};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"removefeedback.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 aResultBlock(nil, nil);
             }
             else
             {
                 NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"This record isn't presented on the server!", nil)};
                 
                 NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                                      code: -1
                                                  userInfo: userInfo];
                 aResultBlock(nil, error);
             }
         }
         else
         {
             aResultBlock(nil, self.internalError);
         }
     }];
}

- (void) insertFeedback: (AIFeedback*) aFeedback
            resultBlock: (void (^)(id responseObject, NSError* error)) aResultBlock
{
    [self.cloudManager sendPOSTrequestWithParameters: [aFeedback descriptionDict]
                                      scriptFileName: @"insertfeedback.php"
                                         resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 aResultBlock(nil, nil);
             }
             else
             {
                 aResultBlock(nil, self.internalError);
             }
         }
         else
         {
             aResultBlock(nil, self.internalError);
         }
     }];
}

- (void) updateFeedback: (AIFeedback*) aFeedback
            resultBlock: (void (^)(id responseObject, NSError* error)) aResultBlock
{
    [self.cloudManager sendPOSTrequestWithParameters: [aFeedback descriptionDict]
                                      scriptFileName: @"updatefeedback.php"
                                         resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 aResultBlock(nil, nil);
             }
             else
             {
                 NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"This record isn't presented on the server!", nil)};
                 
                 NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                                      code: -1
                                                  userInfo: userInfo];
                 aResultBlock(nil, error);
             }
         }
         else
         {
             aResultBlock(nil, self.internalError);
         }
     }];
}

- (void) fetrchFeedbacksFeedForUserID: (NSString*) anUserId
                        friendsIdList: (NSString*) anUsersList
                          resultBlock: (void (^)(NSArray* aFeedbacks, NSArray* votes, NSError* error)) aResultBlock
{
    NSString* userId = anUserId;
    
    if (userId == nil || userId.length == 0)
    {
        userId = @"-1";
    }
    
    NSString* usersList = anUsersList;
    
    if (usersList == nil || usersList.length == 0)
    {
        usersList = @"-1";
    }
    
    // users & userid ==  -1 - all feedbacks
    // users == -1 & userid - all feedbacks of the user's friends0
    // users == @"9,29" userid == -1 - all feedbacks of the 9 and 29 users
    NSDictionary* parameters = @{@"users": usersList, @"userid": userId};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"feedbacksfeed.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, nil, theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 NSArray* feedbacks = (NSArray*) theResponseObject[@"feedbacks"];
                 NSArray* workVotes = (NSArray*) theResponseObject[@"votes"];
                 NSArray* users = (NSArray*) theResponseObject[@"users"];
                 
                 NSMutableArray* votes = [[NSMutableArray alloc] init];
                 
                 if (workVotes.count > 0)
                 {
                     for (NSDictionary* voteDict in workVotes)
                     {
                         NSString* voteid = voteDict[@"voteid"];
                         
                         for (NSDictionary* userDict in users)
                         {
                             if ([voteid isEqualToString: userDict[@"voteid"]])
                             {
                                 NSDictionary* res = @{@"date": voteDict[@"date"],
                                                       @"firstname": userDict[@"firstname"],
                                                       @"lastname": userDict[@"lastname"],
                                                       @"name": userDict[@"name"],
                                                       @"vote": voteDict[@"vote"],
                                                       @"venueid": voteDict[@"venueid"],
                                                       @"venuename": voteDict[@"venuename"],
                                                       @"feedbackid": voteDict[@"feedbackid"]};
                                 [votes addObject: res];
                                 
                                 break;
                             }
                         }
                     }
                 }
                 
                 aResultBlock(feedbacks, votes, nil);
             }
             else
             {
                 aResultBlock(nil, nil, self.internalError);
             }
         }
         else
         {
             NSLog(@"Error while launching of the select_feedbacks.php script!");
             
             aResultBlock(nil, nil, nil);
         }
     }];
}

#pragma mark - Votes

- (void) addVote: (AIVote*) aVote
     resultBlock: (void (^)(NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"userid": aVote.userid, @"feedbackid": aVote.feedbackid, @"device_id": aVote.device_id, @"venueid": aVote.venueid,  @"vote": aVote.like, @"createdAt": aVote.createdAt};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"addvote.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 aResultBlock(nil);
             }
             else
             {
                 NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Sorry, you have voted for this feedback already", nil)};
                 
                 NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                                      code: -1
                                                  userInfo: userInfo];
                 
                 aResultBlock(error);
             }
         }
         else
         {
             aResultBlock(self.internalError);
         }
     }];
}

- (void) fetchVote: (AIVote*) aVote
       resultBlock: (void (^)(id responseObject, NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"feedbackid": aVote.feedbackid, @"venueid": aVote.venueid};
    [self.cloudManager sendGETrequestWithParameters: parameters
                                     scriptFileName: @"selectvote.php"
                                        resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(nil, theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 NSDictionary* dict = @{@"like": theResponseObject[@"like"], @"dislike": theResponseObject[@"dislike"]};
                 aResultBlock(dict, nil);
             }
             else
             {
                 aResultBlock(nil, self.internalError);
             }
         }
         else
         {
             aResultBlock(nil, self.internalError);
         }
     }];
}

#pragma mark - Delete Files on the App Server

- (void) removeDataFileName: (NSString*) aFileName
                resultBlock: (void (^)(NSError* error)) aResultBlock
{
    NSDictionary* parameters = @{@"file": aFileName};
    [self.cloudManager sendPOSTrequestWithParameters: parameters
                                      scriptFileName: @"removedata.php"
                                         resultBlock: ^(id theResponseObject, NSError* theError)
     {
         if (theError)
         {
             aResultBlock(theError);
         }
         else if ([[theResponseObject valueForKey: @"status"] boolValue])
         {
             NSString* result = theResponseObject[@"result"];
             
             if ([result isEqualToString: @"YES"])
             {
                 aResultBlock(nil);
             }
             else
             {
                 NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Failed to remove file from the server!", nil)};
                 NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                                      code: -1
                                                  userInfo: userInfo];
                 aResultBlock(error);
             }
         }
         else
         {
             aResultBlock(self.internalError);
         }
     }];
}

- (NSURL*) photoURLWithFileName: (NSString*) aImageFileName
{
    return [NSURL URLWithString: [NSString stringWithFormat: @"%@/%@", self.imagesStorageFolder, aImageFileName]];
}

- (NSString*) imagesStorageFolder
{
    return kCloudStorageFolderURL;
}

- (NSString*) URLforPingingToApplicationServer
{
    return kCloudPingURL;
}

- (void) uploadDataAsFileName: (NSString*) aFullFileName
                  resultBlock: (void (^)(NSError*, NSString*)) aResultBlock
{
    NSData* data = [NSData dataWithContentsOfFile: aFullFileName];
    NSString* aFileName = [aFullFileName lastPathComponent];
    
    NSString* urlString = [NSString stringWithFormat: @"%@upload_file.php", kCloudRootFolderURL];
    NSMutableURLRequest* request= [[NSMutableURLRequest alloc] init];
    [request setURL: [NSURL URLWithString: urlString]];
    [request setHTTPMethod: @"POST"];
    NSString* boundary = @"---------------------------14737809831466499882746641449";
    NSString* contentType = [NSString stringWithFormat: @"multipart/form-data; boundary=%@", boundary];
    [request addValue: contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData* postbody = [NSMutableData data];
    [postbody appendData: [[NSString stringWithFormat: @"\r\n--%@\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    [postbody appendData: [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n", aFileName] dataUsingEncoding: NSUTF8StringEncoding]];
    [postbody appendData: [[NSString stringWithFormat: @"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
    [postbody appendData: data];
    [postbody appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    [request setHTTPBody: postbody];
    
    NSError* error = nil;
    NSData* returnData = [NSURLConnection sendSynchronousRequest: request
                                               returningResponse: nil
                                                           error: &error];
    if (error)
    {
        aResultBlock(error, nil);
    }
    else
    {
        NSError* jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData: returnData
                                                  options: NSJSONReadingAllowFragments
                                                    error: &jsonError];
        
        if ([json isKindOfClass: [NSDictionary class]])
        {
            NSDictionary* dict = (NSDictionary*) json;
            NSString* result = dict[@"result"];
            NSString* error = dict[@"error"];
            NSString* errorMessage = nil;
            
            if (result && [result isEqualToString: @"error"])
            {
                errorMessage = dict[@"message"];
            }
            else if (error)
            {
                errorMessage = error;
            }
            else
            {
                NSString* fileName = dict[@"file"];
                aResultBlock(nil, fileName);
            }
            
            if (errorMessage)
            {
                NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: errorMessage};
                NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                                     code: -1
                                                 userInfo: userInfo];
                aResultBlock(error, nil);
            }
            
            
        }
        else
        {
            NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Failed format data was received from the server!", nil)};
            
            NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                                 code: -1
                                             userInfo: userInfo];
            
            aResultBlock(error, nil);
        }
    }
}

#pragma mark -

- (NSError*) internalError
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Internal error", nil)
                                                         forKey: NSLocalizedFailureReasonErrorKey];
    NSError* error = [[NSError alloc] initWithDomain: NSNetServicesErrorDomain
                                                code: -1
                                            userInfo: userInfo];
    return error;
}

@end
