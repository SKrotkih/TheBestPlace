//
//  AIDomainObject.m
//  TheBestPlace

#import "AIDomainObject.h"
#import "AILocalDataBase.h"

@implementation AIDomainObject

+ (NSString*) entityName
{
	[self doesNotRecognizeSelector: _cmd];

	return nil;
}

+ (id) disconnectedEntity
{
	NSManagedObjectContext* context = [[AILocalDataBase sharedInstance] managedObjectContext];
	NSEntityDescription* entityDescription = [NSEntityDescription entityForName: [self entityName]
                                                         inManagedObjectContext: context];

	return [[self alloc] initWithEntity: entityDescription
          insertIntoManagedObjectContext: nil];
}

- (void) addToContext: (NSManagedObjectContext*) context
{
	[context insertObject: self];
}

@end
