//
//  AIDirectionOnMapRouter.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 21/09/15.
//  Copyright (c) 2015 Sergey Krotkih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef enum : NSUInteger {
    DirectionTransportWalking,
    DirectionTransportAutomobile
} DirectionTransportType;


@interface AIDirectionOnMapRouter : NSObject

@property(nonatomic, weak) MKMapView* mapView;
@property(nonatomic, assign) DirectionTransportType transportType;
@property(nonatomic, assign) CLLocationCoordinate2D sourceCoordinate;
@property(nonatomic, assign) CLLocationCoordinate2D destinationCoordinate;
@property(nonatomic, strong) UIColor* strokeColor;
@property(nonatomic, assign) CGFloat lineWidth;

- (id) initWithMapView: (MKMapView*) aMapView;
- (void) showRoute;

@end

