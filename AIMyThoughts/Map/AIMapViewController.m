//
//  AIMapViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/11/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIMapViewController.h"
#import "FSVenue.h"
#import "AIVenuesConverter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AICompanyProfileViewController.h"
#import "AIMapAnnotation.h"
#import "AIBuilderRouteOnMapController.h"
#import "AIDirectionOnMapRouter.h"
#import "UIViewController+NavButtons.h"

@interface AIMapViewController () <CLLocationManagerDelegate, UIActionSheetDelegate, MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSArray* nearbyVenues;
@property (copy, nonatomic) CLLocation* myLocation;
@property (strong, nonatomic) AIDirectionOnMapRouter* directionOnMapRouter;

@end

@implementation AIMapViewController
{
    UIActionSheet* _menuActionSheet;
    UIActionSheet* _routeActionSheet;
}

- (id) initWithNibName: (NSString*) nibNameOrNil
                bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
    }

    return self;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    FSVenue* venue = self.sourceViewController.venue;
    NSString* address = venue.location.address;
    
    if (address)
    {
        self.title = venue.location.address;
    }
    else
    {
        self.title = @"";
    }

    [self setLeftBarButtonItemType: BackButtonItem
                        action: @selector(backButtonPressed:)];
    
    UIBarButtonItem* typeMapBarButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"menu.png"]
                                                                         style: UIBarButtonItemStylePlain
                                                                        target: self
                                                                        action: @selector(menuButtonPressed:)];
    
    UIBarButtonItem* routeMapBarButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"distance.png"]
                                                                          style: UIBarButtonItemStylePlain
                                                                         target: self
                                                                         action: @selector(routeButtonPressed:)];
    
    self.navigationItem.rightBarButtonItems = @[typeMapBarButton, routeMapBarButton];
    
    self.nearbyVenues = @[venue];
    [self proccessAnnotations];
    [self startDefiningLocation];
}

#pragma mark -
#pragma mark Define Location

- (void) startDefiningLocation
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if (self.locationManager == nil)
        {
            self.mapView.showsUserLocation = YES;
            self.locationManager = [[CLLocationManager alloc]init];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.delegate = self;
        }
        
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark CLLocationManagerDelegate

- (void) locationManager: (CLLocationManager*) manager
     didUpdateToLocation: (CLLocation*) newLocation
            fromLocation: (CLLocation*) oldLocation
{
    [self.locationManager stopUpdatingLocation];
    
    self.myLocation = newLocation;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self proccessAnnotations];
    });
}

- (void) locationManager: (CLLocationManager*) manager
        didFailWithError: (NSError*) error
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark Map annotation

- (void) proccessAnnotations
{
    [self removeAllAnnotationExceptOfCurrentUser];
    [self.mapView addAnnotations: self.nearbyVenues];
    [self setupMapRegion];
    [self showRoute];
}

- (void) showRoute
{
    if (self.directionOnMapRouter == nil)
    {
        self.directionOnMapRouter = [[AIDirectionOnMapRouter alloc] initWithMapView: self.mapView];
    }
    self.directionOnMapRouter.sourceCoordinate = self.myLocation.coordinate;
    self.directionOnMapRouter.destinationCoordinate = self.sourceViewController.venue.coordinate;
    self.directionOnMapRouter.transportType = DirectionTransportWalking;
    self.directionOnMapRouter.strokeColor = [UIColor redColor];
    self.directionOnMapRouter.lineWidth = 3.0f;
    [self.directionOnMapRouter showRoute];
}

- (void) removeAllAnnotationExceptOfCurrentUser
{
    NSMutableArray* annForRemove = [[NSMutableArray alloc] initWithArray: self.mapView.annotations];
    id lastObject = self.mapView.annotations.lastObject;

    if ([lastObject isKindOfClass: [MKUserLocation class]])
    {
        [annForRemove removeObject: lastObject];
    }
    else
    {
        for (id <MKAnnotation> annot_ in self.mapView.annotations)
        {
            if ([annot_ isKindOfClass: [MKUserLocation class]])
            {
                [annForRemove removeObject: annot_];
                
                break;
            }
        }
    }
    
    [self.mapView removeAnnotations: annForRemove];
}

- (void) setupMapRegion
{
    MKMapRect zoomRect = MKMapRectNull;
    
    if (self.myLocation)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(self.myLocation.coordinate);
        CGFloat x = annotationPoint.x;
        CGFloat y = annotationPoint.y;
        MKMapRect pointRect = MKMapRectMake(x, y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    for (id <MKAnnotation> annotation in self.mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        CGFloat x = annotationPoint.x;
        CGFloat y = annotationPoint.y;
        MKMapRect pointRect = MKMapRectMake(x, y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self.mapView setVisibleMapRect: zoomRect
                           animated: NO];
    [self zoomOutTheMap];
}

- (void) zoomOutTheMap
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    region.center = self.mapView.region.center;
    span.latitudeDelta = self.mapView.region.span.latitudeDelta * 1.9;
    span.longitudeDelta = self.mapView.region.span.longitudeDelta * 1.9;
    region.span = span;
    [self.mapView setRegion: region
                   animated: TRUE];
}

#pragma mark Location Manager

- (MKAnnotationView*) mapView: (MKMapView*) mapView
            viewForAnnotation: (id<MKAnnotation>) annotation
{
    MKAnnotationView* result = nil;

    if (annotation == mapView.userLocation)
    {
        return result;
    }
    
    if ([annotation isKindOfClass: [AIMapAnnotation class]] == NO)
    {
        return result;
    }
    
    if ([mapView isEqual: self.mapView] == NO)
    {
        return result;
    }
    
    AIMapAnnotation* senderAnnotation = (AIMapAnnotation*) annotation;
    NSString* pinReusableIdentifier = [AIMapAnnotation reusableIdentifierforPinColor: senderAnnotation.pinColor];
    MKPinAnnotationView* annotationView = (MKPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier: pinReusableIdentifier];
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation: senderAnnotation
                                                         reuseIdentifier: pinReusableIdentifier];
        annotationView.canShowCallout = YES;
        annotationView.calloutOffset = CGPointMake(0, 0);
    }
    annotationView.image = senderAnnotation.pinImage;
    result = annotationView;
    
    return result;
}

#pragma mark -

- (IBAction) menuButtonPressed: (id) sender
{
    _menuActionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                   delegate: self
                                          cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                     destructiveButtonTitle: nil
                                          otherButtonTitles: NSLocalizedString(@"Standard", nil), NSLocalizedString(@"Satellite", nil), NSLocalizedString(@"Hybrid", nil), nil];
    _menuActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    _menuActionSheet.tintColor = [UIColor blackColor];
    [_menuActionSheet showInView: self.view];
}

- (IBAction) routeButtonPressed: (id) sender
{
    _routeActionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                   delegate: self
                                          cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                     destructiveButtonTitle: nil
                                          otherButtonTitles: NSLocalizedString(@"Google Maps", nil), NSLocalizedString(@"Maps", nil), nil];
    _routeActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    _routeActionSheet.tintColor = [UIColor blackColor];
    [_routeActionSheet showInView: self.view];
}

#pragma mark UIActionSheetDelegate

- (void) willPresentActionSheet: (UIActionSheet*) actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock: ^(UIView* subview, NSUInteger idx, BOOL* stop)
     {
         if ([subview isKindOfClass: [UIButton class]])
         {
             UIButton* button = (UIButton*) subview;
             button.titleLabel.textColor = [UIColor blackColor];
             NSString* buttonText = button.titleLabel.text;
             
             if ([buttonText isEqualToString: NSLocalizedString(@"Cancel", nil)])
             {
                 button.titleLabel.textColor = [UIColor orangeColor];
             }
         }
     }];
}

- (void) actionSheet: (UIActionSheet*) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
    if (actionSheet == _menuActionSheet)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                self.mapView.mapType = MKMapTypeStandard;
                [self proccessAnnotations];
            }
                break;
                
            case 1:
            {
                self.mapView.mapType = MKMapTypeSatellite;
                [self proccessAnnotations];
            }
                break;
                
            case 2:
            {
                self.mapView.mapType = MKMapTypeHybrid;
                [self proccessAnnotations];
            }
                break;
        }
    }
    else if (actionSheet == _routeActionSheet)
    {
        FSVenue* venue = self.sourceViewController.venue;

        switch (buttonIndex)
        {
            case 0:
            {
                [[AIBuilderRouteOnMapController defaultInstance] startPlayMapForViewController: self
                                                                                    myLocation: self.myLocation
                                                                                         venue: venue];
            }
                break;
                
            case 1:
            {
                [[AIBuilderRouteOnMapController defaultInstance] playRouteOnMapsAppWithVenue: venue];
            }
                break;
                
        }
    }
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark Enable only Portrait mode

- (BOOL) shouldAutorotate
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

@end
