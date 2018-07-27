//
//  VenueAnnotation.m
//  TheBestPlace
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import "FSVenue.h"

@implementation FSLocation

@end

@implementation FSVenue

- (id) init
{
    CLLocationCoordinate2D coordinates = {0, 0};
    
    if ((self = [super initWithCoordinates: coordinates
                                     title: nil
                                  subTitle: nil
                                  pinColor: MKPinAnnotationColorRed]))
    {
        self.location = [[FSLocation alloc] init];
    }

    return self;
}

- (CLLocationCoordinate2D) coordinate
{
    return self.location.coordinate;
}

- (NSString*) title
{
    return self.name;
}

- (NSString*) subtitle
{
    return self.location.address;
}

@end
