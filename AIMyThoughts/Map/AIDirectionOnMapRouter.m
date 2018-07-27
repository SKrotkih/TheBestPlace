//
//  AIDirectionOnMapRouter.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 21/09/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//
// http://www.iostute.com/2015/09/how-to-show-driving-route-direction-on.html
// http://developer.skobbler.com/getting-started/ios

#import "AIDirectionOnMapRouter.h"

@interface AIDirectionOnMapRouter() <MKMapViewDelegate>
- (void) showRouteDirection;
@end

@implementation AIDirectionOnMapRouter

- (id) initWithMapView: (MKMapView*) aMapView
{
    if ((self = [super init]))
    {
        _mapView = aMapView;
        _mapView.delegate = self;
    }
    
    return self;
}

- (void) showRoute
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showRouteDirection];
    });
}

- (void) showRouteDirection
{
    if (!self.mapView)
    {
        return;
    }

    MKPlacemark* source = [[MKPlacemark alloc]initWithCoordinate: self.sourceCoordinate
                                               addressDictionary: [NSDictionary dictionaryWithObjectsAndKeys: @"", @"", nil] ];
    MKMapItem* sourceMapItem = [[MKMapItem alloc]initWithPlacemark: source];
    
    MKPlacemark* destination = [[MKPlacemark alloc]initWithCoordinate: self.destinationCoordinate
                                                    addressDictionary: [NSDictionary dictionaryWithObjectsAndKeys: @"", @"", nil] ];
    MKMapItem* distMapItem = [[MKMapItem alloc]initWithPlacemark: destination];
    
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
    [request setSource: sourceMapItem];
    [request setDestination: distMapItem];

    MKDirectionsTransportType directionsTransportType;
    
    switch (self.transportType) {
        case DirectionTransportAutomobile:
            directionsTransportType = MKDirectionsTransportTypeAutomobile;
            break;

        case DirectionTransportWalking:
            directionsTransportType = MKDirectionsTransportTypeWalking;
            break;
            
        default:
            directionsTransportType = MKDirectionsTransportTypeWalking;
            
            break;
    }
    [request setTransportType: directionsTransportType];
    
    MKDirections* direction = [[MKDirections alloc]initWithRequest: request];
    
    [direction calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse* response, NSError* error)
     {
         if (!error)
         {
             for (MKRoute *route in [response routes])
             {
                 [self.mapView addOverlay: [route polyline]
                                    level: MKOverlayLevelAboveRoads];
             }
         }
         
     }];
}

#pragma mark MKMapViewDelegate protocol

- (MKOverlayRenderer*) mapView: (MKMapView*) mapView
            rendererForOverlay: (id<MKOverlay>) overlay
{
    if ([overlay isKindOfClass: [MKPolyline class]])
    {
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay: overlay];
        [renderer setStrokeColor: self.strokeColor ?  self.strokeColor : [UIColor redColor]];
        [renderer setLineWidth: self.lineWidth ? self.lineWidth : 3.0f];
        
        return renderer;
    }
    
    return nil;
}

@end
