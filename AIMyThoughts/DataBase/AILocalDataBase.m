//
//  AILocalDataBase.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/03/14.
//

#import "AILocalDataBase.h"
#import "AIFileManager.h"
#import "AIApplicationServer.h"

NSString* kUserEntityName = @"User";
NSString* kVenueEntityName = @"Venue";
NSString* kCampaignEntityName = @"Campaign";
NSString* kFeedbackEntityName = @"Feedback";

@interface AILocalDataBase()
- (BOOL) updateUserDataWithPredicate: (NSPredicate*) aPredicate
                          forUser: (AIUser*) aNewUser;
- (void) clearAllCurrentUserMark;
- (void) fetchFeedbacksForUserId: (NSString*) aUserId
                         resultBlock: (void(^)(NSArray* aFeedbacks)) aResultBlock;
- (AIUser*) fetchUserWithPredicate: (NSPredicate*) predicate;
@end

@implementation AILocalDataBase
{
    NSMutableArray* _subscriptionIds;
    NSArray* _subscriptions;
    BOOL _isScaningTheDataBaseForSendToServer;
}

+ (AICoreData*) sharedInstance
{
    static AILocalDataBase* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[AILocalDataBase alloc] init];
    });
    
    return instance;
}

#pragma mark - Users

- (void) clearAllCurrentUserMark
{
    [super fetchDataWithPredicate: nil
                       entityName: kUserEntityName
                      resultBlock: ^(NSArray* fetchedObjects)
     {
         for (User* user in fetchedObjects)
         {
             user.currentUser = [NSNumber numberWithBool: NO];
         }
         
         [super saveContext];
     }];
}

- (void) addUser: (AIUser*) aUser
{
    if (!aUser)
    {
        return;
    }
    
    if (aUser.currentUser)
    {
        [self clearAllCurrentUserMark];
    }
    
    User* userData = [NSEntityDescription insertNewObjectForEntityForName: kUserEntityName
                                                   inManagedObjectContext: [self managedObjectContext]];
    [userData saveObject: aUser];
    [super saveContext];
}

- (BOOL) updateUserDataWithPredicate: (NSPredicate*) aPredicate
                          forUser: (AIUser*) aUser
{
    [super fetchDataWithPredicate: aPredicate
                       entityName: kUserEntityName
                      resultBlock: ^(NSArray* fetchedObjects)
     {
         if (fetchedObjects.count > 0)
         {
             if (aUser.currentUser)
             {
                 [self clearAllCurrentUserMark];
             }
             User* userData = fetchedObjects[0];
             [userData saveObject: aUser];
             [super saveContext];
         }
     }];
    
    return YES;
}

- (BOOL) updateUserWithId: (NSString*) aUserID
                   forUser: (AIUser*) aNewUser
{
    if (aUserID == nil || aNewUser == nil)
    {
        return NO;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"userid = %@", aUserID];
    return [self updateUserDataWithPredicate: predicate
                                  forUser: aNewUser];
}

- (BOOL) updateUserWithFbId: (NSString*) aUserID
                     forUser: (AIUser*) aNewUser
{
    if (aUserID == nil || aNewUser == nil)
    {
        return NO;
    }
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"fb_id = %@", aUserID];
    return [self updateUserDataWithPredicate: predicate
                                  forUser: aNewUser];
}

- (AIUser*) currentUser
{
    return [self currentUserInContext: [self managedObjectContext]];
}

- (AIUser*) currentUserInContext: (NSManagedObjectContext*) localContext
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"currentUser = YES"];
    
    __block AIUser* currentUser = nil;
    
    [super fetchDataWithPredicate: predicate
                       entityName: kUserEntityName
                      resultBlock: ^(NSArray* fetchedObjects)
     {
         if (fetchedObjects.count > 0)
         {
             User* user = fetchedObjects[0];
             currentUser = [[AIUser alloc] initWithObject: user];
         }
     }];
    
    return currentUser;
}

- (AIUser*) userWithID: (NSString*) userID
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"userid = %@", userID];
    return [self fetchUserWithPredicate: predicate];
}

- (AIUser*) userWithFbId: (NSString*) facebookID
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"fb_id = %@", facebookID];
    return [self fetchUserWithPredicate: predicate];
}

- (AIUser*) fetchUserWithPredicate: (NSPredicate*) predicate
{
    __block AIUser* user;
    
    [super fetchDataWithPredicate: predicate
                       entityName: kUserEntityName
                      resultBlock: ^(NSArray* fetchedObjects)
     {
         if (fetchedObjects.count > 0)
         {
             User* firstUser = fetchedObjects[0];
             user = [[AIUser alloc] initWithObject: firstUser];
         }
     }];
    
    return user;
}

#pragma mark - Venues

- (void) saveVenues: (NSArray*) aVenues
{
    if (!aVenues)
    {
        return;
    }
    
    NSManagedObjectContext* context = [self managedObjectContext];
    
    for (AIVenue* venue in aVenues)
    {
        Venue* venueData = [NSEntityDescription insertNewObjectForEntityForName: kVenueEntityName
                                                         inManagedObjectContext: context];
        [venueData saveObject: venue];
    }
    [super saveContext];
}

#pragma mark - Campaigns

- (void) saveCampaigns: (NSArray*) aCampaigns
{
    if (!aCampaigns)
    {
        return;
    }
    
    NSManagedObjectContext* context = [self managedObjectContext];
    
    for (AICampaign* campaign in aCampaigns)
    {
        Campaign* campaignData = [NSEntityDescription insertNewObjectForEntityForName: kCampaignEntityName
                                                               inManagedObjectContext: context];
        [campaignData saveObject: campaign];
    }
    [super saveContext];
}

#pragma mark - Feedbacks

- (void) fetchFeedbacksForUserId: (NSString*) aUserId
                         resultBlock: (void(^)(NSArray* aFeedbacks)) aResultBlock
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"userid == %@", aUserId];
    
    [super fetchDataWithPredicate: predicate
                       entityName: kFeedbackEntityName
                      resultBlock: ^(NSArray* fetchedObjects)
     {
         aResultBlock(fetchedObjects);
     }];
}

- (NSMutableArray*) fetchFeedbacksForVenueID: (NSString*) aVenueId
{
    NSMutableArray* feedbacks = [[NSMutableArray alloc] init];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"venueid == %@", aVenueId];
    
    [super fetchDataWithPredicate: predicate
                       entityName: kFeedbackEntityName
                      resultBlock: ^(NSArray* fetchedObjects)
     {
         if (fetchedObjects && [fetchedObjects count] > 0)
         {
             for (Feedback* feedbackObject in fetchedObjects)
             {
                 AIFeedback* feedback = [[AIFeedback alloc] initWithObject: feedbackObject];
                 [feedbacks addObject: feedback];
             }
         }
     }];
    
    return feedbacks;
}

- (NSArray*) feedbacksWithIds: (NSArray*) anFeedbackIds
{
    NSManagedObjectContext* context = [self managedObjectContext];
    NSMutableArray* feedbacks = [[NSMutableArray alloc] init];
    
    for (NSManagedObjectID* objectId in anFeedbackIds)
    {
        NSError* error;
        Feedback* feedbak = (Feedback*)[context existingObjectWithID: objectId
                                                               error: &error];
        [feedbacks addObject: feedbak];
    }
    
    return feedbacks;
}

#pragma mark Delete Feedbacks

- (void) deleteFeedbacks: (NSArray*) aFeedbacks
{
    NSManagedObjectContext* context = self.managedObjectContext;
    
    for (Feedback* feedbackData in aFeedbacks)
    {
        [context deleteObject: feedbackData];
    }
    [super saveContext];
}

- (void) deleteAllFeedbacks
{
    [super fetchDataWithPredicate: nil
                       entityName: kFeedbackEntityName
                      resultBlock: ^(NSArray* fetchedObjects)
     {
         [self deleteFeedbacks: fetchedObjects];
     }];
}

- (void) deleteFeedbackWithId: (NSManagedObjectID*) anObjectID
{
    NSArray* fetchedObjects = [self feedbacksWithIds: @[anObjectID]];
    [self deleteFeedbacks: fetchedObjects];
}

- (void) deleteAllFeedbacksForUserId: (NSString*) aUserId
{
    [self fetchFeedbacksForUserId: aUserId
                          resultBlock: ^(NSArray* fetchedObjects)
     {
         [self deleteFeedbacks: fetchedObjects];
     }];
}

#pragma mark Change Feedback

- (void) insertFeedbacks: (NSArray*) aFeedbacks
{
    if (!aFeedbacks || [aFeedbacks count] == 0)
    {
        return;
    }
    
    NSManagedObjectContext* context = self.managedObjectContext;
    
    for (AIFeedback* feedback in aFeedbacks)
    {
        Feedback* feedbackData = [NSEntityDescription insertNewObjectForEntityForName: kFeedbackEntityName
                                                               inManagedObjectContext: context];
        [feedbackData saveObject: feedback];
    }
    [super saveContext];
}

- (BOOL) updateFeedbackWithID: (NSManagedObjectID*) aFeedbackID
                   tofeedback: (AIFeedback*) aNewFeedback
{
    if (aFeedbackID == nil || aNewFeedback == nil)
    {
        return NO;
    }
    
    NSArray* feedbacks = [self feedbacksWithIds: @[aFeedbackID]];
    
    for (Feedback* feedback in feedbacks)
    {
        [feedback saveObject: aNewFeedback];
    }
    [super saveContext];
    
    return YES;
}

@end
