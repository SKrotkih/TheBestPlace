//
//  AIBuilderRouteOnMapController.h
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/11/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FSVenue.h"

@interface AIBuilderRouteOnMapController : NSObject
{
    UIViewController* parentViewControler;
}

@property (nonatomic, readwrite, strong) UIViewController* parentViewControler;

+ (AIBuilderRouteOnMapController*) defaultInstance;

- (void) startPlayMapForViewController: (UIViewController*) aViewController
                            myLocation: (CLLocation*) myLocation
                                 venue: (FSVenue*) aMmuseum;

- (void) playRouteOnMapsAppWithVenue: (FSVenue*) aVenue;

@end
