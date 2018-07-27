//
//  AICoreData.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 9/22/13.
//

#import <Foundation/Foundation.h>
#import "Feedback.h"
#import "Campaign.h"
#import "User.h"
#import "Venue.h"
#import "AIFeedback.h"
#import "AICampaign.h"
#import "AIUser.h"
#import "AIVenue.h"

@interface AICoreData : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

- (void) addUser: (AIUser*) aUser;

- (AIUser*) currentUser;

- (AIUser*) userWithID: (NSString*) userID;

- (BOOL) updateUserWithId: (NSString*) aUserID
                  forUser: (AIUser*) aNewUser;

- (AIUser*) userWithFbId: (NSString*) facebookID;

- (BOOL) updateUserWithFbId: (NSString*) aUserID
                    forUser: (AIUser*) aNewUser;

- (NSMutableArray*) fetchFeedbacksForVenueID: (NSString*) aVenueId;

- (void) deleteFeedbackWithId: (NSManagedObjectID*) anObjectID;

// Private

- (void) fetchDataWithPredicate: (NSPredicate*) aPredicate
                     entityName: (NSString*) anEntity
                    resultBlock: (void(^)(NSArray* aFeedbacks)) aSyncCallback;

- (void) saveContext;

@end
