//
//  AICoreData.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/03/14.
//

#import "AICoreData.h"
#import "AIFileManager.h"

@implementation AICoreData
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

#pragma mark - Interface Methods Not Implemented

- (void) addUser: (AIUser*) aUser
{
    NSAssert(NO, @"You must implement this method in a child class!");
}

- (AIUser*) currentUser
{
    NSAssert(NO, @"You must implement this method in a child class!");
    return nil;
}

- (AIUser*) userWithID: (NSString*) userID
{
    NSAssert(NO, @"You must implement this method in a child class!");
    return nil;
}

- (BOOL) updateUserWithId: (NSString*) aUserID
                  forUser: (AIUser*) aNewUser
{
    NSAssert(NO, @"You must implement this method in a child class!");
    return NO;
}

- (AIUser*) userWithFbId: (NSString*) facebookID
{
    NSAssert(NO, @"You must implement this method in a child class!");
    return nil;
}

- (BOOL) updateUserWithFbId: (NSString*) aUserID
                    forUser: (AIUser*) aNewUser
{
    NSAssert(NO, @"You must implement this method in a child class!");
    return NO;
}

- (NSMutableArray*) fetchFeedbacksForVenueID: (NSString*) aVenueId
{
    NSAssert(NO, @"You must implement this method in a child class!");
    return nil;
}

- (void) deleteFeedbackWithId: (NSManagedObjectID*) anObjectID
{
    NSAssert(NO, @"You must implement this method in a child class!");
}

#pragma mark - Base Functionality

- (void) fetchDataWithPredicate: (NSPredicate*) aPredicate
                     entityName: (NSString*) anEntity
                    resultBlock: (void(^)(NSArray* aFeedbacks)) aSyncCallback
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    if (aPredicate)
    {
        [fetchRequest setPredicate: aPredicate];
    }
    
    NSManagedObjectContext* context = [self managedObjectContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName: anEntity
                                              inManagedObjectContext: context];
    [fetchRequest setEntity: entity];
    NSError* error;
    NSArray* fetchedObjects = [context executeFetchRequest: fetchRequest
                                                     error: &error];
    aSyncCallback(fetchedObjects);
}

- (void) saveContext
{
    NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil)
    {
        NSError* error = nil;
        
        if ([managedObjectContext hasChanges])
        {
            BOOL success = [managedObjectContext save: &error];
            
            if (!success)
            {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error while writing to the local data base: %@, %@", error, [error userInfo]);
                
                abort();
            }
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext*) managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel*) managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    //    NSURL* modelURL = [[NSBundle mainBundle] URLForResource: @"Model"
    //                                              withExtension: @"mom"];
    
    __managedObjectModel = [NSManagedObjectModel mergedModelFromBundles: nil];
    //    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator*) persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSString* pathToDataBase = [[AIFileManager documentsPath] stringByAppendingPathComponent: @"Model.sqlite"];
    NSURL* storeURL = [NSURL fileURLWithPath: pathToDataBase];
    
    NSError* error = nil;
    NSManagedObjectModel* objectModel = [self managedObjectModel];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: objectModel];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                    configuration: nil
                                                              URL: storeURL
                                                          options: nil
                                                            error: &error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

@end
