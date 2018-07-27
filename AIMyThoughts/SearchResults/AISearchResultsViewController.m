//
//  AISearchVenuesViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/3/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AISearchResultsViewController.h"
#import "UIViewController+NavButtons.h"
#import "AIFoursquareAdapter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AICompanyProfileViewController.h"
#import "AISearchResultsTableViewCell.h"
#import "AIApplicationServer.h"
#import "MBProgressHUD.h"
#import "AINoLocationServiceEnabled.h"
#import "AINetworkMonitor.h"
#import "AIUser.h"

@interface AISearchResultsViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

@property (weak, nonatomic) IBOutlet AINoLocationServiceEnabled* needTurnOnLocationView;
@property (weak, nonatomic) IBOutlet UIImageView *needTurnOnLocationImageView;


@property (strong, nonatomic) CLLocationManager* locationManager;

@property (weak, nonatomic) IBOutlet UIImageView* buttonBgImageView;

@property (strong, nonatomic) FSVenue* selected;
@property (strong, nonatomic) NSArray* nearbyVenues;

@property (strong, nonatomic) AICompanyProfileViewController* companyProfileViewController;

@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, strong) NSMutableDictionary* paramsForRequestToGetVenues;
@property (weak, nonatomic) IBOutlet UIButton *addPlaceButton;

@property (copy, nonatomic) CLLocation* currentLocation;

@property (nonatomic, strong) AIUser* user;
@property (nonatomic, strong) NSMutableArray* allMyFiends;

@end

@implementation AISearchResultsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Search by name", nil);
    self.searchBar.placeholder = NSLocalizedString(@"Some name", nil);
    [self.addPlaceButton setTitle: NSLocalizedString(@"Add Place", nil)
                         forState: UIControlStateNormal];
    
    self.tableView.tableHeaderView = self.tableHeaderView;

    self.paramsForRequestToGetVenues = [@{kLocationKeyFoursquareParameter: @"",
                                          kQueryKeyFoursquareParameter: @"",
                                          kCategoriesKeyFoursquareParameter: @"",
                                          kRadiusKeyFoursquareParameter: [NSNumber numberWithInt: kSearchVenuesRadiusInMeters]} mutableCopy];
    
    self.searchBar.delegate = self;
    
    [self prepareLocationFetchData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: self.refreshControl];
    [self.refreshControl addTarget: self
                            action: @selector(handleRefresh:)
                  forControlEvents: UIControlEventValueChanged];
    
    self.allMyFiends = [[NSMutableArray alloc] init];
    
    [self refreshFriendsList];
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
}

#pragma mark -

- (BOOL) shouldPerformSegueWithIdentifier: (NSString*) identifier
                                   sender: (id) sender
{
    if ([identifier isEqualToString: @"addPlaceSeque"] && ![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark Define Location

- (void) prepareLocationFetchData
{
    if ([CLLocationManager locationServicesEnabled])
    {
        switch ([CLLocationManager authorizationStatus])
        {
                // User has not yet made a choice with regards to this application
            case kCLAuthorizationStatusNotDetermined:
                /* We don't know yet; we have to ask */
                [self createLocationManager];
                
                //    if ([self.locationManager respondsToSelector: @selector(requestAlwaysAuthorization)]) //iOS 8+
                //    {
                //        [self.locationManager requestAlwaysAuthorization];
                //    }
                
                if ([self.locationManager respondsToSelector: @selector(requestWhenInUseAuthorization)]) //iOS 8+
                {
                    [self.locationManager requestWhenInUseAuthorization];
                }
                break;
                
                // Restrictions have been applied; we have no access to location services
            case kCLAuthorizationStatusRestricted:
                [AIAlertView showAlertWythViewController: self
                                                   title: NSLocalizedString(@"Restricted!", nil)
                                                    text: NSLocalizedString(@"Location services are not allowed for this app.", nil)];
                break;
                
                // User has explicitly denied authorization for this application, or
                // location services are disabled in Settings.
            case kCLAuthorizationStatusDenied:
                [AIAlertView showAlertWythViewController: self
                                                   title: NSLocalizedString(@"Not Determined!", nil)
                                                    text: NSLocalizedString(@"Location services are not allowed for this app.", nil)];
                break;
                
            case kCLAuthorizationStatusAuthorizedAlways:
                [self startDefiningLocation];
                break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [self startDefiningLocation];
                break;
        }
        
    }
    else
    {
        [AIAlertView showAlertWythViewController: self
                                           title: NSLocalizedString(@"Warning!", nil)
                                            text: NSLocalizedString(@"Location services are not enabled", nil)];
    }
}

- (void) createLocationManager
{
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
    }
}

- (void) startDefiningLocation
{
    if ([CLLocationManager locationServicesEnabled])
    {
        [self createLocationManager];
        [self.locationManager startUpdatingLocation];
        [MBProgressHUD startProgressWithAnimation: YES];
    }
}

- (void) locationManager: (CLLocationManager*) manager didChangeAuthorizationStatus: (CLAuthorizationStatus) status
{
    [MBProgressHUD stopProgressWithAnimation: YES];
    
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined)
    {
        self.needTurnOnLocationView.hidden = NO;
        [self.view bringSubviewToFront: self.needTurnOnLocationView];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.needTurnOnLocationView.hidden = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [self startDefiningLocation];
    }
}

- (void) locationManager: (CLLocationManager*) manager
     didUpdateToLocation: (CLLocation*) newLocation
            fromLocation: (CLLocation*) oldLocation
{
    [MBProgressHUD stopProgressWithAnimation: YES];
    
    [self.locationManager stopUpdatingLocation];
    self.currentLocation = newLocation;
    self.paramsForRequestToGetVenues[kLocationKeyFoursquareParameter] = newLocation;
    
    [self sendRequestToGetVenues];
}

- (void) locationManager: (CLLocationManager*) manager
        didFailWithError: (NSError*) error
{
    [MBProgressHUD stopProgressWithAnimation: YES];
    [self.locationManager stopUpdatingLocation];
    
    [AIAlertView showAlertWythViewController: self
                                       title: NSLocalizedString(@"Failed to define your location!", nil)
                                        text: [error localizedDescription]];
}

#pragma mark Venues Location

- (void) getVenuesForSearchString: (NSString*) aSearchString
{
    if (aSearchString == nil)
    {
        aSearchString = @"";
    }
    self.paramsForRequestToGetVenues[kQueryKeyFoursquareParameter] = aSearchString;
    
    [self sendRequestToGetVenues];
}

- (void) sendRequestToGetVenues
{
     [MBProgressHUD startProgressWithAnimation: YES];

     [[AIFoursquareAdapter sharedInstance] venuesSearchWithParameters: self.paramsForRequestToGetVenues
                                                   resultBlock: ^(NSArray* aVenues)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (aVenues)
         {
             self.nearbyVenues = aVenues;
             [self.tableView reloadData];
         }
     }];
}

#pragma mark Refresh controlle handler

- (void) handleRefresh: (id) paramSender
{
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        [self.refreshControl endRefreshing];
        
        return;
    }
    
    /* Put a bit of delay between when the refresh control is released
     and when we actually do the refreshing to make the UI look a bit
     smoother than just doing the update without the animation */
    int64_t delayInSeconds = 1.0f;
    dispatch_time_t popTime =
    dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.refreshControl endRefreshing];
        self.searchBar.text = @"";

        [self startDefiningLocation];
    });
}

#pragma mark UISearchBarDelegate

- (void) searchBarSearchButtonClicked: (UISearchBar*) searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void) searchBarTextDidBeginEditing: (UISearchBar*) bar
{
    UITextField *searchBarTextField = nil;
    NSArray *views = ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) ? bar.subviews : [[bar.subviews objectAtIndex:0] subviews];
    
    for (UIView *subview in views)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchBarTextField = (UITextField *)subview;
            break;
        }
    }
    
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (void) searchBarTextDidEndEditing: (UISearchBar*) searchBar
{
    [self.searchBar resignFirstResponder];
    
    [self getVenuesForSearchString: self.searchBar.text];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString* cellIdentifier = @"cell";
    AISearchResultsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier
                                                                         forIndexPath: indexPath];
    FSVenue* venue = self.nearbyVenues[indexPath.row];
    
    cell.nameLabel.text = [venue name];
    
    NSString* imageUrl = [NSString stringWithFormat: @"%@32%@", venue.imageUrlprefix, venue.imageUrlsuffix];
    cell.imageUrl = imageUrl;
    
    if (venue.location.address)
    {
        cell.addressLabel.text = [NSString stringWithFormat: @"%@: %@", NSLocalizedString(@"Address", nil), venue.location.address];
    }
    else
    {
        cell.addressLabel.text = NSLocalizedString(@"Address: N/A", nil);
    }
    
    cell.distanceLabel.text = [NSString stringWithFormat: @"%@ m", venue.location.distance];
    
    return cell;
}

- (void) showProfileOfCompanyForVenue: (FSVenue*) aVenue
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                         bundle: nil];
    self.companyProfileViewController = [storyboard instantiateViewControllerWithIdentifier: @"AICompanyProfileVC"];
    self.companyProfileViewController.venue = aVenue;
    self.companyProfileViewController.allMyFiends = self.allMyFiends;
    [self.navigationController pushViewController: self.companyProfileViewController
                                         animated: YES];
}

#pragma mark - Table view delegate

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    [tableView deselectRowAtIndexPath: indexPath
                             animated: YES];
    
    if (![[AINetworkMonitor sharedInstance] isInternetConnected])
    {
        return;
    }
    
    NSInteger row = indexPath.row;
    self.selected = self.nearbyVenues[row];
    [self showProfileOfCompanyForVenue: self.selected];
}

#pragma mark My Friends List

- (void) refreshFriendsList
{
    if (self.user == nil)
    {
        AIUser* currentUser = [AIUser currentUser];
        
        if (currentUser == nil)
        {
            return;
        }
        
        self.user = currentUser;
    }
    
    [MBProgressHUD startProgressWithAnimation: YES];
    
    NSAssert(self.user != nil, @"User is nil!");
    
    [[AIApplicationServer sharedInstance] fetchFriendsForUserID: self.user.userid
                                            resultBlock: ^(NSArray* friends, NSError* error)
     {
         [MBProgressHUD stopProgressWithAnimation: YES];
         
         if (error)
         {
             NSLog(@"Failed to read data about friends with error: %@", [error localizedDescription]);
         }
         else
         {
             self.allMyFiends = [friends mutableCopy];
         }
     }];
}

#pragma mark -

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction) cancelButtonPressed: (id) sender
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
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
