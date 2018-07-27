//
//  AIApplicationCloudManager.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 10/23/15.
//  Copyright © 2015 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface AIApplicationCloudManager : AFHTTPSessionManager

- (void) sendGETrequestWithParameters: (NSDictionary*) aParameters
                       scriptFileName: (NSString*) aScripFiletName
                          resultBlock: (void (^)(id responseObject, NSError* error)) aResultBlock;

- (void) sendPOSTrequestWithParameters: (id) aParameters
                        scriptFileName: (NSString*) aScripFiletName
                           resultBlock: (void (^)(id responseObject, NSError* error)) aResultBlock;

@end
