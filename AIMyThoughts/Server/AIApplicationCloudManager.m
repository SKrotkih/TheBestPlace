//
//  AIApplicationCloudManager.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 10/23/15.
//  Copyright © 2015 Sergey Krotkih. All rights reserved.
//

#import "AIApplicationCloudManager.h"
#import "AINetworkMonitor.h"
#import "AICloudTrafficTracker.h"

@interface AIApplicationCloudManager()

@property(nonatomic, strong) AICloudTrafficTracker* tracker;

@end


@implementation AIApplicationCloudManager

- (id) initWithBaseURL: (NSURL*) url
{
    if ((self = [super initWithBaseURL: url]))
    {
        self.tracker = [[AICloudTrafficTracker alloc] init];
    }
    
    return self;
}

#pragma mark Send GET request

- (void) sendGETrequestWithParameters: (NSDictionary*) aParameters
                       scriptFileName: (NSString*) aScriptFiletName
                          resultBlock: (void (^)(id aResponseObject, NSError* anError)) aResultBlock
{
    [self isServerConnectedWithResultBlock: ^(NSError* theError)
    {
        if (theError)
        {
            aResultBlock(nil, theError);
            
            return;
        }
        
        [self.tracker willSendRequestType: AICloudRequestGET
                               parameters: aParameters
                           scriptFileName: aScriptFiletName];
        
        [self GET: aScriptFiletName
       parameters: aParameters
          success: ^(NSURLSessionDataTask* theSessionDataTask, id theResponseObject)
         {

             [self.tracker gotResponseType: AICloudRequestGET
                                parameters: aParameters
                            scriptFileName: aScriptFiletName
                            responseObject: theResponseObject];
             
             if (aResultBlock != nil)
             {
                 aResultBlock(theResponseObject, nil);
             }
         }
          failure: ^(NSURLSessionDataTask* theOperation, NSError* theError)
         {

             [self.tracker gotFailureType: AICloudRequestGET
                               parameters: aParameters
                           scriptFileName: aScriptFiletName
                                    error: theError];
             
             if (aResultBlock != nil)
             {
                 aResultBlock(nil, theError);
             }
         }];
    }];
}

#pragma mark Send POST request

- (void) sendPOSTrequestWithParameters: (id) aParameters
                        scriptFileName: (NSString*) aScriptFiletName
                           resultBlock: (void (^)(id aResponseObject, NSError* anError)) aResultBlock
{
    [self isServerConnectedWithResultBlock: ^(NSError* theError)
    {
        if (theError)
        {
            aResultBlock(nil, theError);
            
            return;
        }

        [self.tracker willSendRequestType: AICloudRequestPOST
                               parameters: aParameters
                           scriptFileName: aScriptFiletName];
        
        
        [self POST: aScriptFiletName
        parameters: aParameters
           success: ^(NSURLSessionDataTask* theSessionDataTask, id theResponseObject)
         {
             [self.tracker gotResponseType: AICloudRequestPOST
                                parameters: aParameters
                            scriptFileName: aScriptFiletName
                            responseObject: theResponseObject];
             
             if (aResultBlock != nil)
             {
                 aResultBlock(theResponseObject, nil);
             }
         }
           failure: ^(NSURLSessionDataTask* theOperation, NSError* theError)
         {
             [self.tracker gotFailureType: AICloudRequestPOST
                               parameters: aParameters
                           scriptFileName: aScriptFiletName
                                    error: theError];
             
             if (aResultBlock != nil)
             {
                 aResultBlock(nil, theError);
             }
         }];
    }];
}

#pragma mark Check Connect

- (void) isServerConnectedWithResultBlock: (void(^)(NSError* error)) aResultBlock
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Please, check the Internet connection!", nil)
                                                             forKey: NSLocalizedFailureReasonErrorKey];
        NSError* error = [[NSError alloc] initWithDomain: NSNetServicesErrorDomain
                                                    code: -1
                                                userInfo: userInfo];
        aResultBlock(error);
        
        return;
    }
    
    //    if (_isServerConnected)
    //    {
    //		NSTimeInterval intervSec = [[NSDate date] timeIntervalSinceDate: _lastCheckOfServerDate];
    //
    //        if (intervSec < 30 * 60)
    //        {
    //            aResultBlock(nil);
    //
    //			return;
    //		}
    //    }
    //
    //    _lastCheckOfServerDate = [NSDate date];
    //
    
    [[AINetworkMonitor sharedInstance] checkIfServerAvailableWithResultBlock: ^(NSError* anError){
        aResultBlock(anError);
    }];
}

#pragma mark - Others

- (BOOL) isTokenValid
{
    NSDate* date = [[NSUserDefaults standardUserDefaults] objectForKey: @"expireDate"];
    
    if ([date compare:[NSDate date]] == NSOrderedDescending)
    {
        [[NSUserDefaults standardUserDefaults] setValue: [[NSDate date] dateByAddingTimeInterval: 9500 * 60]
                                                 forKey: @"expireDate"];
        
        return YES;
    }
    else
    {
        [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"Warning", nil)
                                     text: NSLocalizedString(@"Session has expired. Please log in again.", nil)];
        
        return NO;
    }
}

@end
