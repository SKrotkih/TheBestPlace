//
//  AIFoursquareAdapter.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/13/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^AIFoursquareCallback)(BOOL success, NSDictionary* aUserData);
typedef void(^AISearchNearbyCallback)(NSDictionary* aResult);

extern NSString* kLocationKeyFoursquareParameter;
extern NSString* kRadiusKeyFoursquareParameter;
extern NSString* kQueryKeyFoursquareParameter;
extern NSString* kCategoriesKeyFoursquareParameter;

@interface AIFoursquareAdapter : NSObject

+ (AIFoursquareAdapter*) sharedInstance;

- (void) setupFoursquare;

- (BOOL) handleURL: (NSURL*) url;

- (NSString*) authorizationUrl;

- (void) getFriendsForUserID: (NSString*) anUserID
                 resultBlock: (void(^)(BOOL success, id result)) aResultBlock;

- (void) venuesSearchWithLocationCoordinate: (CLLocation*) location
                               resultBlock: (void(^)(NSArray* aVenues)) aResultBlock;

- (void) venuesSearchWithQuery: (NSString*) aQuery
                      location: (NSString*) aLocation
                   resultBlock: (void(^)(NSArray* aVenues, NSError* anError)) aResultBlock;

- (void) venuesSearchWithParameters: (NSDictionary*) aParams
                        resultBlock: (void (^)(NSArray* venues)) aResultBlock;

- (BOOL) isAuthorized;

- (void) authorizeWithResultBlock: (void(^)(BOOL success, id result)) aResultBlock;

- (void) authorizationWithResultBlock: (AIFoursquareCallback) aResultBlock;

- (void) getFoursquareUserIdWithResultBlock: (void(^)(NSString* aUserId)) aResultBlock;

- (void) getUserDataWithResultBlock: (AIFoursquareCallback) aResultBlock;

- (void) shareFeedbackWithUserData: (NSDictionary*) aUserData;

- (void) getCategoriesListToArray: (NSMutableArray*) aCategories
                      resultBlock: (void (^)(NSError* error)) aResultBlock;

- (void) addNewVenueWithParams: (NSDictionary*) aParams
                   resultBlock: (void (^)(NSError* anError)) aResultBlock;

@end
