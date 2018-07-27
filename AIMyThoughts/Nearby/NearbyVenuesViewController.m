//
//  NearbyVenuesViewController.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/20/13.
//
//

#import "NearbyVenuesViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "CheckinViewController.h"
#import "FSConverter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "UsersTipsViewController.h"

@interface NearbyVenuesViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) IBOutlet UIView* footer;

@property (strong, nonatomic) FSVenue* selected;
@property (strong, nonatomic) NSArray* nearbyVenues;

@end

@implementation NearbyVenuesViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Nearby";
    self.tableView.tableHeaderView = self.mapView;
    self.tableView.tableFooterView = self.footer;
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void) updateRightBarButtonStatus
{
    self.navigationItem.rightBarButtonItem.enabled = [Foursquare2 isAuthorized];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    [self updateRightBarButtonStatus];
}

- (void) removeAllAnnotationExceptOfCurrentUser
{
    NSMutableArray* annForRemove = [[NSMutableArray alloc] initWithArray: self.mapView.annotations];

    if ([self.mapView.annotations.lastObject isKindOfClass: [MKUserLocation class]])
    {
        [annForRemove removeObject: self.mapView.annotations.lastObject];
    }
    else
    {
        for (id <MKAnnotation> annot_ in self.mapView.annotations)
        {
            if ([annot_ isKindOfClass: [MKUserLocation class]] )
            {
                [annForRemove removeObject: annot_];

                break;
            }
        }
    }
    
    [self.mapView removeAnnotations: annForRemove];
}

- (void) proccessAnnotations
{
    [self removeAllAnnotationExceptOfCurrentUser];
    [self.mapView addAnnotations: self.nearbyVenues];
}

- (void) getVenuesForLocation: (CLLocation*) location
{
    [Foursquare2 venueSearchNearByLatitude: @(location.coordinate.latitude)
                                 longitude: @(location.coordinate.longitude)
                                     query: nil
                                     limit: nil
                                    intent: intentCheckin
                                    radius: @(500)
                                categoryId: nil
                                  callback: ^(BOOL success, id result){
                                      if (success)
                                      {
                                          NSDictionary* dic = result;
                                          NSArray* venues = [dic valueForKeyPath: @"response.venues"];
                                          FSConverter* converter = [[FSConverter alloc]init];
                                          self.nearbyVenues = [converter convertToObjects: venues];
                                          [self.tableView reloadData];
                                          [self proccessAnnotations];
                                          
                                      }
                                  }];
}

- (void) setupMapForLocatoion: (CLLocation*) newLocation
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.003;
    span.longitudeDelta = 0.003;
    CLLocationCoordinate2D location;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mapView setRegion: region
                   animated: YES];
}

- (void) locationManager: (CLLocationManager*) manager
     didUpdateToLocation: (CLLocation*) newLocation
            fromLocation: (CLLocation*) oldLocation
{
    [self.locationManager stopUpdatingLocation];
    [self getVenuesForLocation: newLocation];
    [self setupMapForLocatoion: newLocation];
}

- (void) locationManager: (CLLocationManager*) manager
        didFailWithError: (NSError*) error
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Table view data source

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.nearbyVenues.count;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    if (self.nearbyVenues.count)
    {
        return 1;
    }

    return 0;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* cellIdentifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath:indexPath];
    FSVenue* venue = self.nearbyVenues[indexPath.row];
    cell.textLabel.text = [venue name];

    if (venue.location.address)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@m, %@", venue.location.distance, venue.location.address];
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@m", venue.location.distance];
    }

    return cell;
}

#pragma mark - Table view delegate

- (void) checkin
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"MainStoryboard" bundle: nil];
    CheckinViewController* checkin = [storyboard instantiateViewControllerWithIdentifier: @"CheckinVC"];
    checkin.venue = self.selected;
    [self.navigationController pushViewController: checkin
                                         animated: YES];
}

- (void) userDidSelectVenue
{
    if ([Foursquare2 isAuthorized])
    {
//        [self checkin];
        
        NSString* venueId = self.selected.venueId;
        [self tipsForVenue: venueId];
	}
    else
    {
        [Foursquare2 authorizeWithCallback: ^(BOOL success, id result)
        {
            if (success)
            {
				[Foursquare2  userGetDetail: @"self"
                                   callback: ^(BOOL success, id result)
                {
                    if (success)
                    {
                        [self updateRightBarButtonStatus];
                        [self checkin];
                    }
                }];
			}
        }];
    }
}

- (void) tipsForVenue: (NSString*) aVenueId
{
    // https://api.foursquare.com/v2/venues/40a55d80f964a52020f31ee3/tips?sort=recent&oauth_token=LHGJNL0AQQB3AI2BUVATNEGHB4BUHVKKE4ZN3SE0DSFFBRJU&v=20140325
    
    [Foursquare2 venueGetTips: aVenueId
                         sort: sortPopular
                        limit: nil
                       offset: nil
                     callback: ^(BOOL success, id result){
                         if (success)
                         {
                             NSDictionary* jsonDict = (NSDictionary*) result;
                             
                             if ([jsonDict[@"meta"][@"code"] integerValue] != 200)
                             {
                                 return;
                             }
                             
                             NSMutableArray* userTips = [[NSMutableArray alloc] init];
                             NSMutableArray* userPhotoURLs = [[NSMutableArray alloc] init];
                             
                             NSDictionary* response = jsonDict[@"response"];
                             
                             
                             NSLog(@"%@", [response description]);

                             
                             NSDictionary* tips = response[@"tips"];
                             NSInteger countTips = [tips[@"count"] integerValue];
                             NSArray* items = tips[@"items"];
                             NSMutableString* likesUsers = [[NSMutableString alloc] init];

                             for (NSDictionary* item in items)
                             {
                                 NSDictionary* likes = item[@"likes"];
                                 NSArray* groups = likes[@"groups"];
                                 
                                 for (NSDictionary* group in groups)
                                 {
                                     NSArray* groupItems = group[@"items"];
                                     
                                     for (NSDictionary* groupItem in groupItems)
                                     {
                                         NSString* groupItemName = [NSString stringWithFormat: @"%@ %@", groupItem[@"firstName"], groupItem[@"lastName"]];
                                         //NSString* groupItemPhotoURL = [NSString stringWithFormat: @"%@%@", groupItem[@"photo"][@"prefix"], groupItem[@"photo"][@"suffix"]];
                                         [likesUsers appendString: groupItemName];
                                     }
                                 }
                                 
                                 NSDictionary* user = item[@"user"];
                                 NSString* userName = [NSString stringWithFormat: @"%@ %@", user[@"firstName"], user[@"lastName"]];
                                 
                                 NSString* userPhotoURL = [NSString stringWithFormat: @"%@40x40%@", user[@"photo"][@"prefix"], user[@"photo"][@"suffix"]];

                                 NSString* inputString = item[@"text"];
                                 NSString* text;
                                 
                                 if ([inputString rangeOfString: @"/U"].location != NSNotFound)
                                 {
                                     text = [self unescapeUnicode: inputString];
                                 }
                                 else
                                 {
                                     text = inputString;
                                 }
                                 
                                 NSString* userTip = nil;
                                 
                                 if ([likesUsers length] > 0)
                                 {
                                     userTip = [NSString stringWithFormat: @"%@: %@ [likes: %@]", userName, text, likesUsers];
                                 }
                                 else
                                 {
                                     userTip = [NSString stringWithFormat: @"%@: %@", userName, text];
                                 }

                                 [userTips addObject: userTip];
                                 [userPhotoURLs addObject: userPhotoURL];
                             }
                             
                             UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"MainStoryboard" bundle: nil];
                             UsersTipsViewController* usersTipsVC = [storyboard instantiateViewControllerWithIdentifier: @"UsersTipsVC"];
                             usersTipsVC.usersTips = userTips;
                             usersTipsVC.userPhotoURLs = userPhotoURLs;
                             usersTipsVC.venueid = aVenueId;
                             [self.navigationController pushViewController: usersTipsVC
                                                                  animated: YES];
                             
                             
                         }
                     }];
}


-(NSString *) unescapeUnicode: (NSString*) input
{
    int x = 0;
    NSMutableString *mStr = [NSMutableString string];
    
    do {
        unichar c = [input characterAtIndex:x];
        if( c == '\\' ) {
            unichar c_next = [input characterAtIndex:x+1];
            if( c_next == 'U' ) {
                
                unichar accum = 0x0;
                int z;
                for( z=0; z<4; z++ ) {
                    unichar thisChar = [input characterAtIndex:x+(2+z)];
                    int val = 0;
                    if( thisChar >= 0x30 && thisChar <= 0x39 ) { // 0-9
                        val = thisChar - 0x30;
                    }
                    else if( thisChar >= 0x41 && thisChar <= 0x46 ) { // A-F
                        val = thisChar - 0x41 + 10;
                    }
                    else if( thisChar >= 0x61 && thisChar <= 0x66 ) { // a-f
                        val = thisChar - 0x61 + 10;
                    }
                    if( z ) {
                        accum <<= 4;
                    }
                    
                    accum |= val;
                }
                NSString *unicode = [NSString stringWithCharacters:&accum length:1];
                [mStr appendString:unicode];
                
                x+=6;
            }
            else {
                [mStr appendFormat:@"%c", c];
                x++;
            }
        }
        else {
            [mStr appendFormat:@"%c", c];
            x++;
        }
    } while( x < [input length] );
    
    return( mStr );
}


- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    self.selected = self.nearbyVenues[indexPath.row];
    [self userDidSelectVenue];
}

- (MKAnnotationView*) mapView: (MKMapView*) mapView viewForAnnotation: (id <MKAnnotation>) annotation
{
    if (annotation == mapView.userLocation)
    {
        return nil;
    }
    
    static NSString* s = @"ann";
    MKAnnotationView* pin = [mapView dequeueReusableAnnotationViewWithIdentifier: s];

    if (!pin)
    {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation: annotation
                                             reuseIdentifier: s];
        pin.canShowCallout = YES;
        pin.image = [UIImage imageNamed: @"pin.png"];
        pin.calloutOffset = CGPointMake(0, 0);
        UIButton* button = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
        [button addTarget: self
                   action: @selector(checkinButton) forControlEvents: UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = button;
        
    }

    return pin;
}

- (void) checkinButton
{
    self.selected = self.mapView.selectedAnnotations.lastObject;
    [self userDidSelectVenue];
}

@end
