//
//  AIDomainObject.h
//  TheBestPlace

#import <CoreData/CoreData.h>

@interface AIDomainObject : NSManagedObject
{
}

+ (NSString*) entityName;
+ (id) disconnectedEntity;
- (void) addToContext: (NSManagedObjectContext*) context;

@end
