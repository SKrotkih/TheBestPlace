//
//  AICloudTrafficTracker.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 10/24/15.
//  Copyright © 2015 Sergey Krotkih. All rights reserved.
//

#import "AICloudTrafficTracker.h"

//#define OUTPUT_LOG_TO_SCREEN

@interface AICloudTrafficTracker()

- (NSString*) descriptionParameters: (id) aParameters;
- (NSString*) descriptionTypeRequest: (AICloudRequestType) aRequestType;
- (NSString*) descriptionResponse: (id) aResponseObject;

@end

@implementation AICloudTrafficTracker

- (void) willSendRequestType: (AICloudRequestType) aRequestType
                  parameters: (id) aParameters
              scriptFileName: (NSString*) aScriptFileName
{
#ifdef OUTPUT_LOG_TO_SCREEN
    NSLog(@"\nSEND %@: %@;\nPARAMS:\n%@", [self descriptionTypeRequest: aRequestType], aScriptFileName, [self descriptionParameters: aParameters]);
#endif
}

- (void) gotResponseType: (AICloudRequestType) aRequestType
              parameters: (id) aParameters
          scriptFileName: (NSString*) aScriptFileName
          responseObject: (id) aResponseObject
{
#ifdef OUTPUT_LOG_TO_SCREEN
    NSLog(@"\nRESPONSE %@: %@;\nPARAMS:\n%@\nRESPONSE:\n%@", [self descriptionTypeRequest: aRequestType],
          aScriptFileName,
          [self descriptionParameters: aParameters],
          [self descriptionResponse: aResponseObject]);
#endif
}

- (void) gotFailureType: (AICloudRequestType) aRequestType
             parameters: (id) aParameters
         scriptFileName: (NSString*) aScriptFileName
                  error: (NSError*) anError
{
#ifdef OUTPUT_LOG_TO_SCREEN
    NSLog(@"\nFAILURE %@: %@;\nPARAMS:\n%@\nERROR:[%@]", [self descriptionTypeRequest: aRequestType], aScriptFileName, [self descriptionParameters: aParameters], [anError localizedDescription]);
#endif
}

#pragma mark Private Methods

- (NSString*) descriptionParameters: (id) aParameters
{
    NSString* descriptionParameters = @"";
    
    if ([aParameters isKindOfClass: [NSDictionary class]])
    {
        descriptionParameters = [(NSDictionary*) aParameters description];
    }
    
    return descriptionParameters;
}

- (NSString*) descriptionTypeRequest: (AICloudRequestType) aRequestType
{
    switch (aRequestType) {
        case AICloudRequestGET:
            return @"GET";

        case AICloudRequestPOST:
            return @"POST";
            
        default:
            break;
    }
    
    return @"Request type is wrong!";
}

- (NSString*) descriptionResponse: (id) aResponseObject
{
    NSString* descriptionResponse = @"";
    
    if ([aResponseObject isKindOfClass: [NSDictionary class]])
    {
        descriptionResponse = [(NSDictionary*) aResponseObject description];
    }
    
    return descriptionResponse;
}

@end
