//
//  AIVenuesConverter.m
//  TheBestPlace
//
//  Created by Constantine Fry on 2/7/13.
//
//

#import "AIVenuesConverter.h"
#import "FSVenue.h"

@implementation AIVenuesConverter

- (NSArray*) convertResponseVenuesToFSVenuesForArray: (NSArray*) venues
{
    if (venues == nil)
    {
        return nil;
    }
    
    NSMutableArray* objects = [NSMutableArray arrayWithCapacity: venues.count];

    for (NSDictionary* dictVenue  in venues)
    {
        FSVenue* venue = [[FSVenue alloc]init];
        venue.name = dictVenue[@"name"];
        venue.venueId = dictVenue[@"id"];
        NSArray* categories = dictVenue[@"categories"];
        
        if (categories && [categories count] > 0)
        {
            NSDictionary* dict = categories[0];
            venue.imageUrlprefix = dict[@"icon"][@"prefix"];
            venue.imageUrlsuffix = dict[@"icon"][@"suffix"];
            venue.categoryid = dict[@"id"];
        }
        venue.location.address = dictVenue[@"location"][@"address"];
        venue.location.distance = dictVenue[@"location"][@"distance"];
        
        [venue.location setCoordinate: CLLocationCoordinate2DMake([dictVenue[@"location"][@"lat"] doubleValue], [dictVenue[@"location"][@"lng"] doubleValue])];
        [objects addObject: venue];
    }
    
    return objects;
}

@end
