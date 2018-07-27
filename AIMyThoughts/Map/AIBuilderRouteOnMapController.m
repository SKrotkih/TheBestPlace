//
//  AIBuilderRouteOnMapController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/11/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//


#import "AIBuilderRouteOnMapController.h"
#import "AIDirectionOnMapRouter.h"

@interface AIBuilderRouteOnMapController ()
@end

@implementation AIBuilderRouteOnMapController
{
    BOOL _isMyLocationPresent;
    BOOL _neeedOpenMapInSafari;
    BOOL _isGoogleMapsAppPresent;
    
    CGFloat _venueLat;
    CGFloat _venueLon;
    CGFloat _myLat;
    CGFloat _myLon;

    FSVenue* _venue;
    
    BOOL _didAppEnterBackground;
    NSTimer* _chekGMTimer;
}

@synthesize parentViewControler;

+ (AIBuilderRouteOnMapController*) defaultInstance
{
    static AIBuilderRouteOnMapController* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[AIBuilderRouteOnMapController alloc] init];
    });
    
    return instance;
}

- (void) startPlayMapForViewController: (UIViewController*) aViewController
                            myLocation: (CLLocation*) myLocation
                                 venue: (FSVenue*) aVenue
{
    self.parentViewControler = aViewController;
    _venue = aVenue;

    _venueLat = _venue.coordinate.latitude;
    _venueLon = _venue.coordinate.longitude;

    if (ABS(_venueLat) < 0.1f && ABS(_venueLon) < 0.1f)
    {
        // Venue's coordinate isn't present
        return;
    }

    _myLat = 0.0f;
    _myLon = 0.0f;
    
    if (myLocation)
    {
        _myLat = myLocation.coordinate.latitude;
        _myLon = myLocation.coordinate.longitude;
    }
    _isMyLocationPresent = ABS(_myLat) > 0.1f && ABS(_myLon) > 0.1f;
    _neeedOpenMapInSafari = NO;
    
    if (SYSTEM_VERSION_GREATER_THAN(@"5.0") && _isMyLocationPresent)
    {
        _isGoogleMapsAppPresent = YES;
        _didAppEnterBackground = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationDidEnterBackground:)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];

         _chekGMTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                        target: self selector: @selector(checkOfGoogleMapStarted)
                                                      userInfo: nil
                                                       repeats: NO];
        
        [self sendRequestForOpenMap];
    }
}

- (void) checkOfGoogleMapStarted
{
    if (_didAppEnterBackground == NO)
    {
        _isGoogleMapsAppPresent = NO;

        _chekGMTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                       target: self selector: @selector(checkOfMapStarted)
                                                     userInfo: nil
                                                      repeats: NO];
        [self sendRequestForOpenMap];
    }
}

- (void) checkOfMapStarted
{
    if (_didAppEnterBackground == NO)
    {
        _isGoogleMapsAppPresent = NO;
        _neeedOpenMapInSafari = YES;

        [self sendRequestForOpenMap];
    }
}

- (void) applicationDidEnterBackground: (UIApplication*) application
{
    _didAppEnterBackground = YES;

    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) sendRequestForOpenMap
{
    NSString* request;
    NSInteger zoom = 12;
    
    NSString* venueLocation = [NSString stringWithFormat: @"%f,%f", _venueLat, _venueLon];
    
    if (_isMyLocationPresent)
    {
        NSString* daddr = [NSString stringWithFormat: @"%f,%f", _myLat, _myLon];
        request = [NSString stringWithFormat: @"saddr=%@&daddr=%@&zoom=%ld&directionsmode=walking", venueLocation, daddr, (long)zoom];
    }
    else
    {
        request = [NSString stringWithFormat: @"center=%@&zoom=%ld&views=satellite", venueLocation, (long)zoom];
    }
    
    NSString* urlString;
    
    if (_neeedOpenMapInSafari)
    {
        urlString = [NSString stringWithFormat: @"http://maps.google.com/maps?%@&key=%@", request, GoogleMapsAPIKeyBrowser];
    }
    else
    {
        NSString* typeMapsApp = _isGoogleMapsAppPresent ? @"comgoogle" : @"";
        
        if (_isGoogleMapsAppPresent)
        {
            urlString = [NSString stringWithFormat: @"%@maps://?%@&key=%@", typeMapsApp, request, GoogleMapsAPIKey];
        }
        else
        {
            urlString = [NSString stringWithFormat: @"%@maps://?%@", typeMapsApp, request];
        }
    }
    
    DLog(@"\n\n%@\n\n", urlString);

    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: urlString]];
}

// By Sedun (p.498)
- (void) playRouteOnMapsAppWithVenue: (FSVenue*) aVenue
{
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    CLLocationCoordinate2D destinationCoordinates = aVenue.coordinate;
    MKPlacemark* destination = [[MKPlacemark alloc] initWithCoordinate: destinationCoordinates
                                                     addressDictionary: nil];
    
    request.destination = [[MKMapItem alloc] initWithPlacemark: destination];
    
    /* Set the transportation method to automobile */
    request.transportType = MKDirectionsTransportTypeWalking;
    
    /* Get the directions */
    MKDirections* directions = [[MKDirections alloc] initWithRequest: request];
    [directions calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse* response, NSError* error)
     {
         
         /* You can manually parse the response but in here we will take
          a shortcut and use the Maps app to display our source and
          destination. We didn't have to make this API call at all
          as we already had the map items before but this is to
          demonstrate that the directions response contains more
          information than just the source and the destination */
         
         /* Display the directions on the Maps app */
         [MKMapItem openMapsWithItems: @[response.source, response.destination]
                        launchOptions: @{
                                         MKLaunchOptionsDirectionsModeKey :
                                             MKLaunchOptionsDirectionsModeDriving
                                         }];
     }];
}







@end
