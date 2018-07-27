//
//  AIFeedback.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIFeedback.h"
#import "AIFileManager.h"
#import "AIApplicationServer.h"
#import "UIDevice+IdentifierAddition.h"
#import "MBProgressHUD.h"
#import "AIApplicationServer.h"

@interface AIFeedback() <UIActionSheetDelegate>
@property (nonatomic, copy) void(^resultBlock)(NSError*);
@end

@implementation AIFeedback
{
    NSString* _photoFileName;
}

@synthesize feedbackid;
@synthesize userid;
@synthesize venueid;
@synthesize categoryid;
@synthesize venuename;

@synthesize createdAt;
@synthesize photo_prefix;
@synthesize photo_suffix;
@synthesize rate;
@synthesize text;
@synthesize name;
@synthesize email;
@synthesize cachePhotoFullFileName = _cachePhotoFullFileName;

@synthesize campaignid;

- (id) init
{
    if ((self = [super init]))
    {
        [[AIApplicationServer sharedInstance] getUserIdWithResultBlock: ^(NSString* aUserId){
            if (aUserId)
            {
                self.userid = aUserId;
            }
            else
            {
                self.userid = @"";
            }
        }];
        
        self.rate = @0;
        self.text = @"";
        self.name = @"";
        self.email = @"";
    }
    
    return self;
}

- (id) initWithObject: (Feedback*) aFeedback
{
    if ((self = [self init]))
    {
        self.feedbackid = aFeedback.feedbackid;
        self.userid = aFeedback.userid;
        self.venueid = aFeedback.venueid;
        self.venuename = @"";
        
        self.createdAt = aFeedback.createdAt;
        self.photo_prefix = aFeedback.photo_prefix;
        self.photo_suffix = aFeedback.photo_suffix;
        self.rate = aFeedback.rate;
        self.text = aFeedback.text;
        self.name = aFeedback.name;
        self.email = aFeedback.email;
        
        self.campaignid = aFeedback.campaignid;
        self.objectId = aFeedback.objectID;
    }
    
    return self;
}

- (id) initWithDict: (NSDictionary*) aDict
{
    if ((self = [self init]))
    {
        self.userid = aDict[@"userid"];
        self.device_id = aDict[@"device_id"];
        self.venueid = aDict[@"venueid"];
        self.categoryid = aDict[@"categoryid"];
        self.venuename = aDict[@"venuename"];
        self.feedbackid = aDict[@"id"];
        
        self.email = aDict[@"email"];
        self.name = aDict[@"name"];
        self.createdAt = [NSNumber numberWithDouble: [aDict[@"createdAt"] doubleValue]];
        self.photo_prefix = aDict[@"photo_prefix"];
        self.photo_suffix = aDict[@"photo_suffix"];
        self.rate = [NSNumber numberWithInteger: [aDict[@"rate"] integerValue]];
        self.text = aDict[@"text"];
    }
    
    return self;
}

- (id) initWithDict: (NSDictionary*) aDict
             userId: (NSString*) aUserId
{
    if ((self = [self initWithDict: aDict]))
    {
        self.userid = aUserId;
    }
    
    return self;
}

- (void) dealloc
{
}

- (NSDictionary*) descriptionDict
{
    if (self.feedbackid == nil)
    {
        self.feedbackid = @"";
    }
    if (self.photo_prefix == nil)
    {
        self.photo_prefix = @"";
    }
    if (self.photo_suffix == nil)
    {
        self.photo_suffix = @"";
    }
    if (self.text == nil)
    {
        self.text = @"";
    }
    if (self.name == nil)
    {
        self.name = @"";
    }
    if (self.email == nil)
    {
        self.email = @"";
    }
    if (self.device_id == nil)
    {
        self.device_id = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    }
    
    NSDictionary* dict = @{@"feedbackid": self.feedbackid,
                           @"email": self.email,
                           @"device_id": self.device_id,
                           @"createdAt": self.createdAt,
                           @"photo_prefix": self.photo_prefix,
                           @"photo_suffix": self.photo_suffix,
                           @"rate": self.rate,
                           @"text": self.text,
                           @"name": self.name,
                           @"venueid": self.venueid,
                           @"categoryid": self.categoryid,
                           @"venuename": self.venuename,
                           @"userid": self.userid};
    
    return dict;
}

- (NSString*) stringOfDateCreatedAt
{
    CFTimeInterval theTimeInterval = [createdAt doubleValue];
    NSDate* datePublished = [NSDate dateWithTimeIntervalSince1970: theTimeInterval];
    NSString* dateString = [NSDateFormatter localizedStringFromDate: datePublished
                                                          dateStyle: NSDateFormatterMediumStyle
                                                          timeStyle: NSDateFormatterNoStyle];
    
    return dateString;
}

- (void) saveTheEditDateAsCurrent
{
    CFTimeInterval theTimeInterval = [[NSDate date] timeIntervalSince1970];
    self.createdAt = [NSNumber numberWithDouble: theTimeInterval];
}

#pragma mark Property

- (NSString*) userName
{
    if (self.name && self.name.length > 0)
    {
        return self.name;
    }
    
    return NSLocalizedString(@"Anonymous", nil);
}


#pragma mark Photo

- (void) setCachePhotoFullFileName: (NSString*) cachePhotoFullFileName
{
    if (cachePhotoFullFileName)
    {
        _cachePhotoFullFileName = [cachePhotoFullFileName copy];
    }
    else
    {
        _cachePhotoFullFileName = nil;
    }
}

- (NSString*) photoFileName
{
    if (_photoFileName)
    {
        return _photoFileName;
    }
    else if ([self.photo_suffix length] > 0)
    {
        _photoFileName = self.photo_suffix;
    }
    else
    {
        _photoFileName = [[NSString stringWithFormat: @"photo%@.png", [[NSProcessInfo processInfo] globallyUniqueString]] copy];
    }

    return _photoFileName;
}

- (NSString*) cachePhotoFullFileName
{
    if (_cachePhotoFullFileName == nil)
    {
        NSString* photoFileName = [self photoFileName];
        _cachePhotoFullFileName = [[[AIFileManager cachePath] stringByAppendingPathComponent: photoFileName] copy];
    }
    
    return _cachePhotoFullFileName;
}

- (void) downloadPhotoWithResultBlock: (void (^)(NSError*)) aResultBlock
                              view: (UIView*) aView
{
    if (self.photo_suffix && self.photo_suffix.length > 0)
    {
        NSString* photoFullFileName = self.cachePhotoFullFileName;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: photoFullFileName])
        {
            aResultBlock(nil);
        }
        else
        {
            [MBProgressHUD startProgressWithAnimation: YES];
            
            [[AIApplicationServer sharedInstance] downloadDataFileName: self.photo_suffix
                                                  destFullPath: photoFullFileName
                                                   resultBlock: ^(NSError* error)
             {
                 [MBProgressHUD stopProgressWithAnimation: YES];
                 
                 aResultBlock(error);
             }];
        }
    }
    else
    {
        aResultBlock(nil);
    }
}

- (NSURL*) photoURL
{
    if (self.photo_suffix && self.photo_suffix.length > 0)
    {
        return [[AIApplicationServer sharedInstance] photoURLWithFileName: self.photo_suffix];
    }
    else
    {
        return nil;
    }
}

- (void) savePhoto: (UIImage*) anImagePhoto
        resultBlock: (void (^)(NSError*)) aResultBlock
{
    NSData* imageData = UIImagePNGRepresentation(anImagePhoto);
//    NSData* imageData = UIImageJPEGRepresentation(anImagePhoto, 1.0);

    NSString* photoFileName = self.cachePhotoFullFileName;
    
    if ([imageData writeToFile: photoFileName
                     atomically: NO])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            aResultBlock(nil);
        });
    }
    else
    {
        self.cachePhotoFullFileName = nil;
        NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat: NSLocalizedString(@"Image file %@ was not saved to cache!", nil), photoFileName]};
        NSError* error = [NSError errorWithDomain: kTheMainErrorsDomain
                                             code: -1
                                         userInfo: userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            aResultBlock(error);
        });
    }
}

- (void) uploadPhotoWithResultBlock: (void (^)(NSError*)) aResultBlock
{
    NSString* cachePhotoFileName = self.cachePhotoFullFileName;
    
    if (cachePhotoFileName && [[NSFileManager defaultManager] fileExistsAtPath: cachePhotoFileName])
    {
        [MBProgressHUD startProgressWithAnimation: YES];
        
        [[AIApplicationServer sharedInstance] uploadDataAsFileName: cachePhotoFileName
                                               resultBlock: ^(NSError* anError, NSString* aFileName)
         {
             [MBProgressHUD stopProgressWithAnimation: YES];
             
             if (anError)
             {
                 aResultBlock(anError);
             }
             else
             {
                 self.photo_prefix = @"";
                 self.photo_suffix = aFileName;
                 
                 aResultBlock(nil);
             }
         }];
    }
    else
    {
        self.photo_prefix = @"";
        self.photo_suffix = @"";
        
        [self removePhotoWithResultBlock: ^(NSError* error)
         {
             aResultBlock(nil);
         }];
    }
}

#pragma mark Update Feedback on database

- (void) insertToDataBaseWithResultBlock: (void (^)(NSError*)) aCoolback
                                    view: (UIView*) aView
{
    [self saveTheEditDateAsCurrent];
    
    [self uploadPhotoWithResultBlock: ^(NSError* aError)
     {
         if (aError)
         {
             aCoolback(aError);
         }
         else
         {
             [[AIApplicationServer sharedInstance] insertFeedback: self
                                                        resultBlock: ^(NSArray *aFeedbacks, NSError *error)
              {
                  aCoolback(error);
              }];
         }
     }];
}

- (void) updateDataWithNeedToSavePhoto: (BOOL) aNeedSavePhoto
                       resultBlock: (void (^)(NSError*)) aCoolback
{
    [self saveTheEditDateAsCurrent];
    
    if (aNeedSavePhoto)
    {
        [self uploadPhotoWithResultBlock: ^(NSError* aError)
         {
             if (aError)
             {
                 aCoolback(aError);
             }
             else
             {
                 [[AIApplicationServer sharedInstance] updateFeedback: self
                                                     resultBlock: ^(NSArray *aFeedbacks, NSError *error)
                  {
                      aCoolback(error);
                  }];
             }
         }];
    }
    else
    {
        [[AIApplicationServer sharedInstance] updateFeedback: self
                                            resultBlock: ^(NSArray *aFeedbacks, NSError *error)
         {
             aCoolback(error);
         }];
    }
}

#pragma mark Remove Photo

- (void) removePhotoWithResultBlock: (void (^)(NSError*)) aResultBlock
{
    NSString* cachePhotoFileName = self.cachePhotoFullFileName;
    NSString* dataFileName = [cachePhotoFileName lastPathComponent];
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    [[AIApplicationServer sharedInstance] removePhoto: dataFileName
                                     resultBlock: ^(NSError* aError)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (aError)
         {
             aResultBlock(aError);
         }
         else
         {
             [self clearPhotoCache];
             
             aResultBlock(nil);
         }
     }];
}

- (void) clearPhotoCache
{
    NSString* cachePhotoFileName = self.cachePhotoFullFileName;
    
    if (cachePhotoFileName && [[NSFileManager defaultManager] fileExistsAtPath: cachePhotoFileName])
    {
        NSError* error;

        if (![[NSFileManager defaultManager] removeItemAtPath: cachePhotoFileName
                                                        error: &error])
        {
            NSLog(@"Unable to delete the file: %@ [%@]", cachePhotoFileName, [error localizedDescription]);
        }
    }
}

#pragma mark Remove feedback

- (void) removeFeedbackWithResultBlock: (void (^)(NSError*)) aResultBlock
                                      view: (UIView*) aView
{
    self.resultBlock = aResultBlock;
    
    AIUser* currentUser = [AIUser currentUser];
    
    if ([self.userid isEqualToString: currentUser.userid])
    {
        UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"This feedback will be deleted. Are you sure?", nil)
                                                           delegate: self
                                                  cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                             destructiveButtonTitle: nil
                                                  otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
        [sheet showInView: aView];
        
    }
    else
    {
        
    }
}

- (void) actionSheet: (UIActionSheet*) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 0)
    {
        [[AIApplicationServer sharedInstance] removeFeedback: self
                                            resultBlock: ^(NSArray* aFeedbacks, NSError* error)
         {
             if (error)
             {
                 self.resultBlock(error);
             }
             else
             {
                 [self clearPhotoCache];
                 self.resultBlock(nil);
             }
         }];
    }
}


#pragma mark Check: Is It My Feedback?

- (void) isItMyFeedbackWithResultBlock: (void(^)(BOOL isItMyFeedback)) aResultBlock
                      checkDeviceId: (BOOL) needCheckDeviceId
{
    [[AIApplicationServer sharedInstance] getUserIdWithResultBlock: ^(NSString* aUserId){
        if (aUserId && [aUserId isEqualToString: self.userid])
        {
            aResultBlock(YES);
        }
        else
        {
            if (needCheckDeviceId)
            {
                if ([self.device_id isEqualToString: [[UIDevice currentDevice] uniqueDeviceIdentifier]])
                {
                    aResultBlock(YES);
                }
            }
            else
            {
                aResultBlock(NO);
            }
        }
    }];
}

@end
