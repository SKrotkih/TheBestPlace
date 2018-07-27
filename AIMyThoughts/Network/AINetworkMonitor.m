//
//  AINetworkMonitor.m
//  ePublishing
//
//  Created by Sergey Krotkih on 3/6/13.
//

#import "AINetworkMonitor.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "AIReachability.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include "AIAppDelegate.h"
#include "AIApplicationServer.h"

const CGFloat TimerIntervalInSec = 5.0f;

@interface AINetworkMonitor ()
- (void) scanInternetTimerFired: (NSTimer*) timer;
@end

@implementation AINetworkMonitor
{
    NSTimer* _timer;
}

+ (AINetworkMonitor*) sharedInstance
{
    static AINetworkMonitor* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[AINetworkMonitor alloc] init];
    });
    
    return instance;
}

- (BOOL) isInternetConnected
{
    return [self checkInternetConnectionWithNeedAlert: YES];
}

- (BOOL) checkInternetConnectionWithNeedAlert: (BOOL) aNeedAlert
{
    AIReachability* networkReachability = [AIReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    if (networkStatus == NotReachable)
    {
        if (aNeedAlert)
        {
            UIWindow* window = [AIAppDelegate sharedDelegate].window;
            UIViewController* viewController = window.rootViewController;
            
            [AIAlertView showAlertWythViewController: viewController
                                               title: NSLocalizedString(@"No Internet Connection", nil)
                                                text: NSLocalizedString(@"An Internet connection is unavailable. Some features of this application require an active connection.", nil)];
        }
        
        if (_timer == nil)
        {
            [self startMonitoringInternet];
        }
        
        return NO;
    }
    else
    {
        if (_timer)
        {
            [_timer invalidate];
            _timer = nil;
        }
        
        return YES;
    }
}

- (void) startMonitoringInternet
{
    if (!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval: TimerIntervalInSec
                                                  target: self
                                                selector: @selector(scanInternetTimerFired:)
                                                userInfo: nil
                                                 repeats: YES];
    }
    
    [self checkInternetConnectionWithNeedAlert: NO];
}

- (void) scanInternetTimerFired: (NSTimer*) timer
{
    if(timer == _timer)
    {
        [self checkInternetConnectionWithNeedAlert: NO];
    }
    else
    {
        NSAssert(NO, @"Unexpected timer");
    }
}

- (BOOL) checkInternetConnectionForDownloadData
{
    BOOL goAhead = YES;
    
    AIReachability* networkReachability = [AIReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    switch(networkStatus)
    {
        case ReachableViaWiFi:
            // There's a wifi connection, go ahead and download

            break;
        case ReachableViaWWAN:
            // There's only a cell connection, so you may or may not want to download
            goAhead = NO;
            
            break;
        case NotReachable:
            // No connection at all! Bad signal, or perhaps airplane mode?
            goAhead = NO;

            break;
    }
    
    return goAhead;
}

- (void) checkIfServerAvailableWithResultBlock: (void(^)(NSError* error)) aResultBlock
{
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSString* hostName = [[AIApplicationServer sharedInstance] URLforPingingToApplicationServer];
        AIReachability* reachability = [AIReachability reachabilityWithHostName: hostName];
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        NSError* error = nil;
        
        if (netStatus == NotReachable)
        {
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Our server isn't available. Please, try again after some time.", nil)
                                                                 forKey: NSLocalizedFailureReasonErrorKey];
            error = [[NSError alloc] initWithDomain: @"AFNetworkingErrorDomain"
                                               code: -1
                                           userInfo: userInfo];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            aResultBlock(error);
        });
    });
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return outstring;
}


@end
