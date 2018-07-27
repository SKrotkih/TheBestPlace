//
//  AIFeedback.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feedback.h"

@protocol AIFeedbackDataBaseDelegate <NSObject>
- (void) insertFeedbacks: (NSArray*) aFeedbacks;
- (BOOL) updateFeedbackWithID: (NSManagedObjectID*) aFeedbackID
                   tofeedback: (AIFeedback*) aNewFeedback;
@end

@interface AIFeedback : NSObject
{
    NSString* _cachePhotoFullFileName;
}

@property (nonatomic, copy) NSString* feedbackid;
@property (nonatomic, copy) NSString* device_id;
@property (nonatomic, copy) NSString* userid;
@property (nonatomic, copy) NSString* venueid;
@property (nonatomic, copy) NSString* categoryid;
@property (nonatomic, copy) NSString* venuename;

@property (nonatomic, copy) NSNumber* createdAt;
@property (nonatomic, copy) NSString* photo_prefix;
@property (nonatomic, copy) NSString* photo_suffix;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, retain) NSNumber* rate;

@property (nonatomic, copy) NSManagedObjectID* objectId;
@property (nonatomic, copy) NSString* campaignid;

@property (nonatomic, copy) NSString* cachePhotoFullFileName;

- (id) initWithObject: (Feedback*) aFeedback;

- (id) initWithDict: (NSDictionary*) aDict;

- (id) initWithDict: (NSDictionary*) aDict
             userId: (NSString*) aUserId;

- (NSString*) stringOfDateCreatedAt;

- (void) downloadPhotoWithResultBlock: (void (^)(NSError*)) aResultBlock
                              view: (UIView*) aView;

- (void) savePhoto: (UIImage*) anImagePhoto
        resultBlock: (void (^)(NSError*)) aResultBlock;

- (void) insertToDataBaseWithResultBlock: (void (^)(NSError*)) aResultBlock
                                    view: (UIView*) aView;

- (void) updateDataWithNeedToSavePhoto: (BOOL) aNeedSavePhoto
                       resultBlock: (void (^)(NSError*)) aResultBlock;

- (void) removePhotoWithResultBlock: (void (^)(NSError*)) aResultBlock;

- (void) removeFeedbackWithResultBlock: (void (^)(NSError*)) aResultBlock
                               view: (UIView*) aView;

- (void) clearPhotoCache;

- (NSDictionary*) descriptionDict;

- (void) isItMyFeedbackWithResultBlock: (void(^)(BOOL isItMyFeedback)) aResultBlock
                      checkDeviceId: (BOOL) needCheckDeviceId;

- (NSString*) userName;

- (NSURL*) photoURL;

@end
