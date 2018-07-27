//
//  FSVenue.h
//  TheBestPlace
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AIMapAnnotation.h"

@interface FSLocation : NSObject
{
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSNumber* distance;
@property (nonatomic, copy) NSString* address;

@end

@interface FSVenue : AIMapAnnotation

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* venueId;
@property (nonatomic,strong) FSLocation* location;
@property (nonatomic, copy) NSString* imageUrlprefix;
@property (nonatomic, copy) NSString* imageUrlsuffix;
@property (nonatomic, copy) NSString* categoryid;

@end
