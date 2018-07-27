//
//  AIFoursquareAdapter.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/13/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFoursquareAdapter.h"
#import "AIVenuesConverter.h"
#import "FSVenue.h"
#import "Foursquare2.h"
#import "AIAppDelegate.h"
#import "AIFoursquareAuthViewController.h"
#import "AINetworkMonitor.h"
#import "MBProgressHUD.h"

const NSString* kLocationKeyFoursquareParameter = @"location";
const NSString* kRadiusKeyFoursquareParameter = @"radius";
const NSString* kQueryKeyFoursquareParameter = @"query";
const NSString* kCategoriesKeyFoursquareParameter = @"categories";


@interface AIFoursquareAdapter()
- (NSDictionary*) parseUserForData: (NSDictionary*) aUserData;
- (void) userGetDetail: (AIFoursquareCallback) aResultBlock;
- (void) checkInWithData: (NSDictionary*) aUserData
               needAlert: (BOOL) aNeedAlert;

@property (nonatomic, copy) Foursquare2Callback authCallback;
@end

@implementation AIFoursquareAdapter
{
    AIFoursquareAuthViewController* _authViewController;
    UIImageView* _currScreenshot;
    NSMutableArray* _categories;
}

+ (AIFoursquareAdapter*) sharedInstance
{
    static AIFoursquareAdapter* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[AIFoursquareAdapter alloc] init];
    });
    
    return instance;
}

- (void) setupFoursquare
{
    [Foursquare2 setupFoursquareWithClientId: FoursquareClientId
                                      secret: FoursquareClientSecret
                                 callbackURL: FoursquareCallbackUrl];
}

- (BOOL) handleURL: (NSURL*) url
{
    return [Foursquare2 handleURL: url];
}

#pragma mark - Authorization

- (NSString*) authorizationUrl
{
    return [Foursquare2 authorizationUrl];
}

- (BOOL) isAuthorized
{
    return [Foursquare2 isAuthorized];
}

- (void) authorizeWithResultBlock: (void(^)(BOOL success, id result)) aResultBlock
{
    [Foursquare2 authorizeWithCallback: ^(BOOL success, id result)
     {
         aResultBlock(success, result);
     }];
}

- (void) authorizationWithResultBlock: (AIFoursquareCallback) aResultBlock
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        aResultBlock(NO, nil);
        
        return;
    }
    
    if ([self isAuthorized])
    {
        aResultBlock(YES, nil);
        
        return;
    }
    
    self.authCallback = aResultBlock;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Settings_iPhone"
                                                         bundle: nil];
    
    _authViewController = [storyboard instantiateViewControllerWithIdentifier: @"FQAuthorizationVC"];
    
    [[Foursquare2 sharedInstance] setUpAuthorizeCallback: ^(BOOL success, id result)
     {
         [self dismissAuthorizeViewController: success
                                       result: result];
     }];
    
    _currScreenshot = [[AIAppDelegate sharedDelegate] takeWindowScreenshot];
    
    [[AIAppDelegate sharedDelegate] presentModalViewController: _authViewController];
    
    [[AIAppDelegate sharedDelegate].window addSubview: _currScreenshot];
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
}

- (void) dismissAuthorizeViewController: (BOOL) aSuccess
                                 result: (id) aResult
{
    [_authViewController dismissViewControllerAnimated: NO
                                            completion: nil];
    
    [MBProgressHUD stopProgressWithAnimation: NO];
    
    [_currScreenshot removeFromSuperview];
    _currScreenshot = nil;
    
    self.authCallback(aSuccess, aResult);
    
    _authViewController = nil;
    self.authCallback = nil;
}

#pragma mark - Friends

- (void) getFriendsForUserID: (NSString*) anUserID
                 resultBlock: (void(^)(BOOL success, id result)) aResultBlock
{
    [Foursquare2 userGetFriends: anUserID
                          limit: nil
                         offset: nil
                       callback: ^(BOOL success, id result)
     {
         aResultBlock(success, result);
     }];
}

#pragma mark - Get Users Data

- (void) userGetDetail: (AIFoursquareCallback) aResultBlock
{
    [Foursquare2 userGetDetail: @"self"
                      callback: ^(BOOL theSuccess, id theResult)
     {
         if (theSuccess)
         {
             NSDictionary* dict = [self parseUserForData: theResult];
             
             //             NSDictionary* dict = @{@"firstName": @"Sergey", @"lastName": @"Krotkih", @"userEmail": @"svmp@ukr.net", @"userId": @"38578883"};
             
             aResultBlock(theSuccess, dict);
         }
         else
         {
             NSLog(@"Get details about me failed!");
             aResultBlock(theSuccess, nil);
         }
     }
     ];
}

- (void) getFoursquareUserIdWithResultBlock: (void(^)(NSString* aUserId)) aResultBlock
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userId = [defaults stringForKey: kQFoursquareUserIdDefaultValue];
    
    //    NSString* userId = @"38578884";
    
    if (userId && [userId length] > 0)
    {
        aResultBlock(userId);
    }
    else
    {
        [self getUserDataWithResultBlock: ^(BOOL success, NSDictionary* aUserData)
         {
             
             if (success)
             {
                 
                 if (aUserData)
                 {
                     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                     NSString* userId = aUserData[@"userId"];
                     [defaults setObject: userId
                                  forKey: kQFoursquareUserIdDefaultValue];
                     [defaults synchronize];
                     
                     aResultBlock(userId);
                 }
             }
             else
             {
                 NSLog(@"Get details about me failed!");
             }
         }];
    }
}

- (void) getUserDataWithResultBlock: (AIFoursquareCallback) aResultBlock
{
    if ([self isAuthorized])
    {
        [self userGetDetail: aResultBlock];
    }
    else
    {
        // Login
        [self authorizeWithResultBlock: ^(BOOL success, id result)
         {
             if (success)
             {
                 [self userGetDetail: aResultBlock];
             }
             else
             {
                 aResultBlock(success, nil);
             }
         }];
    }
}

- (NSDictionary*) parseUserForData: (NSDictionary*) aUserData
{
    if (aUserData &&  [aUserData isKindOfClass: [NSDictionary class]])
    {
        NSDictionary* dict = (NSDictionary*) aUserData;
        NSString* firstName = [dict valueForKeyPath: @"response.user.firstName"];
        NSString* lastName = [dict valueForKeyPath: @"response.user.lastName"];
        NSString* userId = [dict valueForKeyPath: @"response.user.id"];
        NSString* userEmail = [dict valueForKeyPath: @"response.user.contact.email"];
        NSDictionary* userData = @{@"firstName": firstName,
                                   @"lastName": lastName,
                                   @"userId" : userId,
                                   @"userEmail": userEmail};
        
        return userData;
    }
    
    return nil;
}

#pragma mark - Share Feedback

- (void) shareFeedbackWithUserData: (NSDictionary*) aUserData
{
    if ([self isAuthorized])
    {
        [self checkInWithData: aUserData
                    needAlert: YES];
    }
    else
    {
        // Login
        [self authorizeWithResultBlock: ^(BOOL success, id result)
         {
             if (success)
             {
                 [self checkInWithData: aUserData
                             needAlert: YES];
             }
         }];
    }
}

#pragma mark - Check In

- (void) checkInWithData: (NSDictionary*) aUserData
               needAlert: (BOOL) aNeedAlert
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    [Foursquare2 tipAdd: aUserData[@"text"]
               forVenue: aUserData[@"venueId"]
                withURL: aUserData[@"url"]
               callback: ^(BOOL success, id result)
     {
         if (success)
         {
             if (aNeedAlert)
             {
                 [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"Congrats!", nil)
                                              text: NSLocalizedString(@"New tip added to the venue", nil)];
             }
         }
         else
         {
             NSError* error = (NSError*) result;
             [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"Error", @"Error")
                                          text: [error localizedDescription]];
         }
     }];
}

#pragma mark - Add New Venue

- (void) addNewVenueWithParams: (NSDictionary*) aParams
                   resultBlock: (void (^)(NSError* anError)) aResultBlock
{
    [self authorizationWithResultBlock: ^(BOOL success, id result){
        
        if (!success)
        {
            NSError* error = (NSError*) result;
            aResultBlock(error);
            
            return;
        }
        
        /**
         Add new venue.
         @discussion returns in callback block "venue" field.
         @returns The instance of NSOperation already inqueued in internal operation queue.
         Callback block will not be called, if you send cancel message to the operation.
         Venue object that was created: https://developer.foursquare.com/docs/responses/venue
         */
        
        NSNumber* latitude = aParams[@"latitude"];
        NSNumber* longitude = aParams[@"longitude"];
        NSString* name = aParams[@"name"];
        NSString* phone = aParams[@"phone"];
        NSString* twitter = aParams[@"twitter"];
        NSString* address = aParams[@"address"];
        NSString* primaryCategoryId = aParams[@"primaryCategoryId"];
        NSString* crossStreet = aParams[@"crossStreet"];
        NSString* city = aParams[@"city"];
        NSString* state = aParams[@"state"];
        NSString* zip = aParams[@"zip"];
        
        [Foursquare2 venueAddWithName: name
                              address: address
                          crossStreet: crossStreet
                                 city: city
                                state: state
                                  zip: zip
                                phone: phone
                              twitter: twitter
                          description: nil
                             latitude: latitude
                            longitude: longitude
                    primaryCategoryId: primaryCategoryId
                             callback: ^(BOOL success, id result)
         {
             if (success)
             {
                 NSString* venueId = [self parseNewVenueResult: result];
                 
                 if (venueId)
                 {
                     NSDictionary* userData = @{@"text": @"The Best Place", @"venueId": venueId, @"url": @""};
                     
                     [self checkInWithData: userData
                                 needAlert: NO];
                 }
                 
                 aResultBlock(nil);
             }
             else
             {
                 NSError* error = (NSError*) result;
                 aResultBlock(error);
                 
                 return;
             }
         }];
    }];
    
}

- (NSString*) parseNewVenueResult: (id) aResponce
{
    if ([aResponce isKindOfClass: [NSDictionary class]])
    {
        NSDictionary* responce = aResponce;
        NSDictionary* venue = [responce valueForKeyPath: @"response.venue"];
        NSString* venueId = venue[@"id"];
        
        return venueId;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Serarch Venues

- (void) venuesSearchWithQuery: (NSString*) aQuery
                      location: (NSString*) aLocation
                   resultBlock: (void(^)(NSArray* aVenues, NSError* anError)) aResultBlock
{
    [Foursquare2 venueSearchNearLocation: aLocation
                                   query: aQuery
                                   limit: nil
                                  intent: intentBrowse
                                  radius: @(500)
                              categoryId: nil
                                callback: ^(BOOL success, id result)
     {
         if (success)
         {
             NSDictionary* dic = result;
             NSArray* venues = [dic valueForKeyPath: @"response.venues"];
             AIVenuesConverter* converter = [[AIVenuesConverter alloc] init];
             NSArray* nearbyVenues = [converter convertResponseVenuesToFSVenuesForArray: venues];
             aResultBlock(nearbyVenues, nil);
         }
         else
         {
             aResultBlock(nil, result);
         }
     }];
}

- (void) venuesSearchWithLocationCoordinate: (CLLocation*) aLocation
                                resultBlock: (void(^)(NSArray* aVenues)) aResultBlock
{
    [Foursquare2 venueSearchNearByLatitude: @(aLocation.coordinate.latitude)
                                 longitude: @(aLocation.coordinate.longitude)
                                     query: nil
                                     limit: nil
                                    intent: intentCheckin
                                    radius: @(500)
                                categoryId: nil
                                  callback: ^(BOOL theSuccess, id theResult)
     {
         if (theSuccess)
         {
             NSDictionary* dic = (NSDictionary*)theResult;
             NSArray* venues = [dic valueForKeyPath: @"response.venues"];
             AIVenuesConverter* converter = [[AIVenuesConverter alloc] init];
             NSArray* theNearVenues = [converter convertResponseVenuesToFSVenuesForArray: venues];
             aResultBlock(theNearVenues);
         }
         else
         {
             aResultBlock(nil);
         }
     }];
}

- (void) venuesSearchWithParameters: (NSDictionary*) aParams
                        resultBlock: (void (^)(NSArray* venues)) aResultBlock
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        aResultBlock(nil);
        
        return;
    }
    
    [self primaryCategoryIdsWithCallback: ^(NSError* theError, NSString* theCategoryId)
     {
         if (theError)
         {
             NSLog(@"%@", [theError description]);
             
             return;
         }
         
         if (theCategoryId)
         {
             CLLocation* location = aParams[kLocationKeyFoursquareParameter];
             NSNumber* radius = aParams[kRadiusKeyFoursquareParameter];
             NSString* query = aParams[kQueryKeyFoursquareParameter];
             NSString* categoryId = aParams[kCategoriesKeyFoursquareParameter];
             
             [Foursquare2 venueSearchNearByLatitude: @(location.coordinate.latitude)
                                          longitude: @(location.coordinate.longitude)
                                              query: query
                                              limit: nil
                                             intent: intentCheckin
                                             radius: radius
                                         categoryId: categoryId
                                           callback: ^(BOOL theSuccess, id theResult)
              {
                  if (theSuccess)
                  {
                      NSArray* venues = [self parseSearchResult: theResult];
                      aResultBlock(venues);
                  }
                  else
                  {
                      NSError* error = (NSError*) theResult;
                      [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"Error", @"Error")
                                                   text: [error localizedDescription]];
                  }
              }];
         }
     }];
}

- (NSArray*) parseSearchResult: (id) aResponce
{
    if ([aResponce isKindOfClass: [NSDictionary class]])
    {
        NSDictionary* responce = aResponce;
        NSArray* objects = [responce valueForKeyPath: @"response.venues"];
        AIVenuesConverter* converter = [[AIVenuesConverter alloc] init];
        NSArray* result = [converter convertResponseVenuesToFSVenuesForArray: objects];
        
        NSArray* venues = [result sortedArrayUsingComparator: ^NSComparisonResult(id a, id b){
            FSVenue* venue1 = (FSVenue*)a;
            FSVenue* venue2 = (FSVenue*)b;
            double first = [venue1.location.distance doubleValue];
            double second = [venue2.location.distance doubleValue];
            
            return first > second;
        }];
        
        return venues;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Categories

- (void) getCategoriesListToArray: (NSMutableArray*) aCategories
                      resultBlock: (void (^)(NSError* error)) aResultBlock
{
    if (_categories)
    {
        for (NSMutableDictionary* dict in _categories)
        {
            [aCategories addObject: dict];
        }
        
        aResultBlock(nil);
        
        return;
    }
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [Foursquare2 venueGetCategoriesCallback: ^(BOOL success, id result)
     {
         
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (success)
         {
             [self parseCategoriesWithResponce: result
                                  toCategories: aCategories];
             
             aResultBlock(nil);
         }
         else
         {
             NSError* error = (NSError*) result;
             aResultBlock(error);
         }
     }];
}

- (void) primaryCategoryIdsWithCallback: (void (^)(NSError* error, NSString* categoriyIds)) aResultBlock
{
    NSMutableString* categoryIds = [[NSMutableString alloc] initWithString: @""];
    NSMutableArray* categories = [[NSMutableArray alloc] init];
    
    [self getCategoriesListToArray: categories
                       resultBlock: ^(NSError* error)
     {
         if (error)
         {
             aResultBlock(error, nil);
         }
         else
         {
             for (NSDictionary* dict in categories)
             {
                 if ([dict[@"level"] integerValue] == 0)
                 {
                     NSString* categoryId = dict[@"id"];
                     [categoryIds appendFormat: @"%@,", categoryId];
                 }
             }
             
             NSString* returnValue = [categoryIds substringToIndex: categoryIds.length - 1];
             
             aResultBlock(nil, returnValue);
         }
         
     }];
}

- (void) parseCategoriesWithResponce: (id) aResponce
                        toCategories: (NSMutableArray*) aCategories
{
    _categories = [[NSMutableArray alloc] init];
    
    NSDictionary* dict = (NSDictionary*) aResponce;
    NSDictionary* response = dict[@"response"];
    NSArray* categories = response[@"categories"];
    
    for (NSDictionary* category in categories)
    {
        NSString* name = category[@"name"];
        NSString* categoryId = category[@"id"];
        NSDictionary* icon = category[@"icon"];
        NSString* iconFile = [NSString stringWithFormat: @"%@32%@", icon[@"prefix"], icon[@"suffix"]];
        NSDictionary* item = @{@"level": @"0", @"name": name, @"iconurl": iconFile, @"id": categoryId, @"parentid": @"", @"checked": [NSNumber numberWithBool: NO]};
        [_categories addObject: [item mutableCopy]];
        [aCategories addObject: [item mutableCopy]];
        
        NSArray* categories = category[@"categories"];
        
        for (NSDictionary* subcategory in categories)
        {
            NSString* name = subcategory[@"name"];
            NSDictionary* icon = subcategory[@"icon"];
            NSString* iconFile = [NSString stringWithFormat: @"%@32%@", icon[@"prefix"], icon[@"suffix"]];
            NSDictionary* item = @{@"level": @"1", @"name": name, @"iconurl": iconFile, @"id": subcategory[@"id"], @"parentid": categoryId, @"checked": [NSNumber numberWithBool: NO]};
            [_categories addObject: [item mutableCopy]];
            [aCategories addObject: [item mutableCopy]];
        }
    }
}

@end
