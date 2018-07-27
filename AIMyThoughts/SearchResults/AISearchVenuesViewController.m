//
//  AISearchVenuesViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AISearchVenuesViewController.h"
#import "AIFoursquareAdapter.h"
#import "FSVenue.h"
#import "AIVenuesConverter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AICompanyProfileViewController.h"
#import "UIViewController+NavButtons.h"

@interface AISearchVenuesViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

@property (strong, nonatomic) CLLocationManager* locationManager;

@property (strong, nonatomic) FSVenue* selected;
@property (strong, nonatomic) NSArray* nearbyVenues;

@property (strong, nonatomic) AICompanyProfileViewController* companyProfileViewController;

@end

@implementation AISearchVenuesViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Search", nil);
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];

    self.tableView.tableHeaderView = self.tableHeaderView;

    [self startDefiningLocation];
}

- (void) updateRightBarButtonStatus
{
    self.navigationItem.rightBarButtonItem.enabled = [[AIFoursquareAdapter sharedInstance] isAuthorized];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self updateRightBarButtonStatus];
}

#pragma mark Map annotation

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

- (void) venueSearchNearLocation: (CLLocation*) location
{
    [[AIFoursquareAdapter sharedInstance] venuesSearchWithLocationCoordinate: location
                                                         resultBlock: ^(NSArray* theNearVenues)
    {
        if (theNearVenues)
        {
            self.nearbyVenues = theNearVenues;
            [self.tableView reloadData];
            [self proccessAnnotations];
        }
    }];
}

- (void) getVenuesForSearchString: (NSString*) aSearchString
{
    if (!aSearchString || aSearchString.length == 0)
    {
        return;
    }
    
    NSArray* arr = [aSearchString componentsSeparatedByString: @","];
    NSString* location = nil;
    NSString* query = nil;
    
    if ([arr count] != 2)
    {
        location = arr[0];
        query = nil;
    }
    else
    {
        location = arr[0];
        query = arr[1];
    }
    
    [[AIFoursquareAdapter sharedInstance] venuesSearchWithQuery: query
                                                location: location
                                             resultBlock: ^(NSArray* theNearVenues, NSError* anError)
     {
         if (theNearVenues)
         {
             self.nearbyVenues = theNearVenues;
             [self.tableView reloadData];
             [self proccessAnnotations];
         }
         else
         {
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error", @"Error")
                                                 text: [anError localizedDescription]];
         }
     }];
}

- (void) setupMapRegionForLocatoion: (CLLocation*) newLocation
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

#pragma mark -
#pragma mark Define Location

- (void) startDefiningLocation
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if (self.locationManager == nil)
        {
            self.locationManager = [[CLLocationManager alloc]init];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.delegate = self;
        }
        
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark Location Manager

- (void) locationManager: (CLLocationManager*) manager
     didUpdateToLocation: (CLLocation*) newLocation
            fromLocation: (CLLocation*) oldLocation
{
    [self.locationManager stopUpdatingLocation];
    [self venueSearchNearLocation: newLocation];
    [self setupMapRegionForLocatoion: newLocation];
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
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ m, %@", venue.location.distance, venue.location.address];
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ m", venue.location.distance];
    }

    return cell;
}

- (void) showProfileOfCompanyForVenue: (FSVenue*) aVenue
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                         bundle: nil];
    self.companyProfileViewController = [storyboard instantiateViewControllerWithIdentifier: @"AICompanyProfileVC"];
    self.companyProfileViewController.venue = aVenue;
    [self.navigationController pushViewController: self.companyProfileViewController
                                         animated: YES];
}

#pragma mark - Table view delegate

- (void) didSelectVenue: (FSVenue*) aVenue
{
    if ([[AIFoursquareAdapter sharedInstance] isAuthorized])
    {
        [self showProfileOfCompanyForVenue: aVenue];
    }
    else
    {
        [[AIFoursquareAdapter sharedInstance] authorizeWithResultBlock: ^(BOOL theRuccess, id theResult)
         {
             if (theRuccess)
             {
                 [self showProfileOfCompanyForVenue: aVenue];
             }
         }];
    }
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    self.selected = self.nearbyVenues[indexPath.row];
    [self didSelectVenue: self.selected];
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
    [self didSelectVenue: self.selected];
}

- (IBAction) nearbyButtonPressed: (id) sender
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    [self startDefiningLocation];
}

#pragma mark UISearchBarDelegate

- (void) searchBarSearchButtonClicked: (UISearchBar*) searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void) searchBarTextDidEndEditing: (UISearchBar*) searchBar
{
    [self.searchBar resignFirstResponder];
    
    NSString* searchString = self.searchBar.text;

    if (searchString.length > 0)
    {
        [self getVenuesForSearchString: searchString];
    }
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark Enable only Portrait mode

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -

@end
