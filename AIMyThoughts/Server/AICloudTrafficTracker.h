//
//  AICloudTrafficTracker.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 10/24/15.
//  Copyright © 2015 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AICloudRequestGET,
    AICloudRequestPOST
} AICloudRequestType;

@interface AICloudTrafficTracker : NSObject

- (void) willSendRequestType: (AICloudRequestType) aRequestType
                       parameters: (id) aParameters
                   scriptFileName: (NSString*) aScriptFileName;

- (void) gotResponseType: (AICloudRequestType) aRequestType
              parameters: (id) aParameters
          scriptFileName: (NSString*) aScriptFileName
          responseObject: (id) aResponseObject;

- (void) gotFailureType: (AICloudRequestType) aRequestType
             parameters: (id) aParameters
         scriptFileName: (NSString*) aScriptFileName
                  error: (NSError*) anError;


@end
