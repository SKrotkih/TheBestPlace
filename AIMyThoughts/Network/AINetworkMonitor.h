//
//  AINetworkMonitor.h
//  //  ePublishing
//
//  Created by Sergey Krotkih on 3/6/13.
//

#import <Foundation/Foundation.h>

@interface AINetworkMonitor : NSObject

+ (AINetworkMonitor*) sharedInstance;
- (NSString*) macaddress;

- (BOOL) isInternetConnected;

- (void) checkIfServerAvailableWithResultBlock: (void(^)(NSError* error)) aResultBlock;
- (BOOL) checkInternetConnectionForDownloadData;

@end
