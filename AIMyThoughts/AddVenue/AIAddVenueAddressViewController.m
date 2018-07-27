
//
//  AIAddVenueAddressViewController.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 4/27/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIAddVenueAddressViewController.h"
#import "AIFoursquareAdapter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AICategoriesTableViewController.h"
#import "UIView+Shake.h"
#import "AIMapAnnotation.h"
#import "UIViewController+NavButtons.h"

@interface AIAddVenueAddressViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *addPlaceButton;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSMutableArray* categories;
@end

@implementation AIAddVenueAddressViewController
{
    MKCoordinateRegion _region;
    CLLocationCoordinate2D _location;
    AIMapAnnotation* _point;
    AddressCategoryTableViewCell* _categoryTableViewCell;
    AddressAddressTableViewCell* _addressTableViewCell;
    AddressNameTableViewCell* _nameTableViewCell;
    AddressPhoneTableViewCell* _phoneTableViewCell;
    AddressTwitterTableViewCell* _twitterTableViewCell;
    
    BOOL _isShowedAddressTable;
}

- (id)initWithNibName: (NSString*) nibNameOrNil
               bundle: (NSBundle*) nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"New Place", nil);
    
    [self.addPlaceButton setTitle: NSLocalizedString(@"Save Place", nil)
                         forState: UIControlStateNormal];
    
    self.categories = [[NSMutableArray alloc] init];
    
    [self setLeftBarButtonItemType: BackButtonItem
                            action: @selector(backButtonPressed:)];
    
    [self setRightBarButtonItemType: AddButtonItem
                             action: @selector(addPlaceButtonPressed:)];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    CGFloat height = 0.0f;
    
    switch (row)
    {
        case 0:
            height = 44.0f;   // Name
            
            break;
        case 1:
            height = 44.0f;   // Phone
            
            break;
        case 2:
            height = 44.0f;   // Twitter
            
            break;
        case 3:
        {
            if (_isShowedAddressTable)
            {
                height = 6 * 45.0f;   // Address
            }
            else
            {
                height = 44.0f;
            }
        }
            
            break;
        case 4:
            height = 44.0f;
            
            break;
        case 5:
            height = 200.0f;   // Location
            
            break;
            
        default:
            break;
    }
    
    return height;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    switch (row)
    {
        case 0:
        {
            _nameTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"NameCell"];
            _nameTableViewCell.nameTextField.placeholder = NSLocalizedString(@"Name", nil);
            
            return _nameTableViewCell;
        }
            break;
        case 1:
        {
            _phoneTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"PhoneCell"];
            _phoneTableViewCell.phoneTextField.placeholder = NSLocalizedString(@"Phone", nil);
            
            return _phoneTableViewCell;
        }
            break;
        case 2:
        {
            _twitterTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"TwitterCell"];
            _twitterTableViewCell.twitterTextField.placeholder = NSLocalizedString(@"Twitter", nil);
            
            return _twitterTableViewCell;
        }
            
            break;
        case 3:
        {
            _addressTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"AddressCell"];
            _addressTableViewCell.delegate = self;
            _addressTableViewCell.addressHeaderView.delegate = self;
            _addressTableViewCell.addressHeaderView.addressLabel.text = NSLocalizedString(@"Address:", nil);
            
            return _addressTableViewCell;
        }
            
            break;
        case 4:
        {
            _categoryTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"CategoryCell"];
            _categoryTableViewCell.categoryHeaderView.delegate = self;
            _categoryTableViewCell.categoryHeaderView.categoryLabel.text = NSLocalizedString(@"Category:", nil);
            
            return _categoryTableViewCell;
        }
            
            break;
        case 5:
        {
            AddressLocationTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"LocationCell"];
            
            //            if (_point)
            {
                cell.mapView.hidden = NO;
                cell.mapView.mapType = MKMapTypeHybrid;
                cell.mapView.delegate = self;
                cell.mapView.showsUserLocation = YES;
                //                [self addAnnotationOnMap: cell.mapView];
            }
            //            else
            //            {
            //                cell.mapView.hidden = YES;
            //            }
            
            return cell;
        }
            
            break;
            
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark AddressHeaderViewDelegate

- (void) addressHeaderViewPressed
{
    _isShowedAddressTable = !_isShowedAddressTable;
    [self.mainTableView reloadData];
}

#pragma mark AddressTableViewCellDelegate

- (void) addressWasChanged
{
    _addressTableViewCell.addressHeaderView.addressValueLabel.text = _addressTableViewCell.streetTableViewCell.addressStreetTextField.text;
}

#pragma mark CategoryHeaderViewDelegate

- (void) categoryHeaderViewPressed
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main_iPhone"
                                                         bundle: nil];
    AICategoriesTableViewController* categoriesTVC = [storyboard instantiateViewControllerWithIdentifier: @"AICategoriesTVC"];
    categoriesTVC.delegate = self;
    categoriesTVC.allCategories = NO;
    categoriesTVC.categories = self.categories;
    [self.navigationController pushViewController: categoriesTVC
                                         animated: YES];
}

- (void) selectedCategories: (NSArray*) aSelectedCategoriesArray
              allCategories: (BOOL) anAllCategories;
{
    NSLog(@"You should not call this method here!");
}

#pragma mark

- (void) selectCategory: (NSDictionary*) aCategoryDict
{
    NSString* categoryId = aCategoryDict[@"id"];
    NSString* categoryName = aCategoryDict[@"name"];
    
    _categoryTableViewCell.categoryHeaderView.categoryValueLabel.text = categoryName;
    _categoryTableViewCell.categoryHeaderView.categoryId = categoryId;
}

#pragma mark -

- (BOOL) checkData
{
    NSString* name = _nameTableViewCell.nameTextField.text;
    
    if (name.length == 0)
    {
        [_nameTableViewCell shake];
        
        return NO;
    }
    
    if (_categoryTableViewCell.categoryHeaderView.categoryId == nil || _categoryTableViewCell.categoryHeaderView.categoryId.length == 0)
    {
        [_categoryTableViewCell.categoryHeaderView shake];
        
        return NO;
    }
    
    return YES;
}

#pragma mark Button Pressed Handlers

- (void) backButtonPressed: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction) addPlaceButtonPressed: (id) sender
{
    NSNumber* latitude = [NSNumber numberWithDouble: _location.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble: _location.longitude];
    
    if (!latitude || !longitude || (latitude == 0 && longitude == 0))
    {
        NSString* text = NSLocalizedString(@"Sorry. Information about your location is not accessible. You can't add a new address.", nil);
        
        [AIAlertView showAlertWythViewController: self
                                           title: @""
                                            text: text];
        
        return;
    }
    
    if (![self checkData])
    {
        return;
    }
    
    NSString* name = _nameTableViewCell.nameTextField.text;
    NSString* primaryCategoryId = _categoryTableViewCell.categoryHeaderView.categoryId;
    
    NSString* phone = _phoneTableViewCell.phoneTextField.text;
    phone = phone == nil? @"": phone;
    NSString* twitter = _twitterTableViewCell.twitterTextField.text;
    twitter = twitter == nil? @"": twitter;
    NSString* address = _addressTableViewCell.streetTableViewCell.addressStreetTextField.text;
    address = address == nil? @"": address;
    NSString* crossStreet = _addressTableViewCell.crossstreetTableViewCell.addressStreetTextField.text;
    crossStreet = crossStreet == nil? @"": crossStreet;
    NSString* city = _addressTableViewCell.cityTableViewCell.addressCityTextField.text;
    city = city == nil? @"": city;
    NSString* state = _addressTableViewCell.stateTableViewCell.addressStateTextField.text;
    state = state == nil? @"": state;
    NSString* zip = _addressTableViewCell.zipTableViewCell.addressZipTextField.text;
    zip = zip == nil? @"": zip;
    
    NSDictionary* params = @{@"latitude": latitude,
                             @"longitude": longitude,
                             @"name": name,
                             @"phone": phone,
                             @"twitter": twitter,
                             @"address": address,
                             @"primaryCategoryId": primaryCategoryId,
                             @"crossStreet": crossStreet,
                             @"city": city,
                             @"state": state,
                             @"zip": zip};
    
    [[AIFoursquareAdapter sharedInstance] addNewVenueWithParams: params
                                             resultBlock: ^(NSError* anError)
     {
         if (anError)
         {
             [AIAlertView showAlertWythViewController: self
                                                title: NSLocalizedString(@"Error", @"Error")
                                                 text: [anError localizedDescription]];
         }
         else
         {
             [self.navigationController popViewControllerAnimated: YES];
         }
     }];
}

#pragma mark Map

- (void) mapView: (MKMapView*) aMapView didUpdateUserLocation: (MKUserLocation*) aUserLocation
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    _location.latitude = aUserLocation.coordinate.latitude;
    _location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = _location;
    [aMapView setRegion: region
               animated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark -

@end

#pragma mark Name

@interface AddressNameTableViewCell() <UITextFieldDelegate>

@end

@implementation AddressNameTableViewCell
- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void) shake
{
    [UIView shakeView: _nameTextField];
}

@end

#pragma mark Phone

@interface AddressPhoneTableViewCell() <UITextFieldDelegate>

@end

@implementation AddressPhoneTableViewCell
- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end

#pragma mark Twitter

@interface AddressTwitterTableViewCell() <UITextFieldDelegate>


@end

@implementation AddressTwitterTableViewCell
- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end

#pragma mark Address

@interface AddressAddressTableViewCell()  <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *addressTableView;
@end

@implementation AddressAddressTableViewCell

#pragma mark UITableViewDelegate

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSInteger row = indexPath.row;
    
    switch (row)
    {
        case 0:
        {
            self.streetTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"AddressStreet"];
            self.streetTableViewCell.delegate = self.delegate;
            self.streetTableViewCell.addressStreetTextField.placeholder = NSLocalizedString(@"Address", nil);
            self.streetTableViewCell.addressStreetTextField.text = @"";
            
            return self.streetTableViewCell;
        }
            
            break;
            
        case 1:
        {
            self.crossstreetTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"AddressCrossStreet"];
            self.crossstreetTableViewCell.delegate = self.delegate;
            self.crossstreetTableViewCell.addressStreetTextField.placeholder = NSLocalizedString(@"Cross Street", nil);
            self.crossstreetTableViewCell.addressStreetTextField.text = @"";
            
            return self.crossstreetTableViewCell;
        }
            
            break;
            
        case 2:
        {
            self.cityTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"AddressCity"];
            self.cityTableViewCell.delegate = self.delegate;
            self.cityTableViewCell.addressCityTextField.placeholder = NSLocalizedString(@"City", nil);
            self.cityTableViewCell.addressCityTextField.text = @"";
            
            return self.cityTableViewCell;
        }
            
            break;
            
        case 3:
        {
            self.stateTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"AddressState"];
            self.stateTableViewCell.delegate = self.delegate;
            self.stateTableViewCell.addressStateTextField.placeholder = NSLocalizedString(@"State", nil);
            self.stateTableViewCell.addressStateTextField.text = @"";
            
            return self.stateTableViewCell;
        }
            
            break;
            
        case 4:
        {
            self.zipTableViewCell = [tableView dequeueReusableCellWithIdentifier: @"AddressZip"];
            self.zipTableViewCell.delegate = self.delegate;
            self.zipTableViewCell.addressZipTextField.placeholder = NSLocalizedString(@"Zip", nil);
            self.zipTableViewCell.addressZipTextField.text = @"";
            
            return self.zipTableViewCell;
        }
            
            break;
            
        default:
            break;
    }
    
    return nil;
}

@end

@interface AddressStreetTableViewCell() <UITextFieldDelegate>

@end

@implementation AddressStreetTableViewCell

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [self.delegate addressWasChanged];
    [textField resignFirstResponder];
    
    return YES;
}

@end


@interface AddressCityTableViewCell() <UITextFieldDelegate>
@end


@implementation AddressCityTableViewCell
- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [self.delegate addressWasChanged];
    [textField resignFirstResponder];
    
    return YES;
}

@end


@interface AddressStateTableViewCell() <UITextFieldDelegate>
@end

@implementation AddressStateTableViewCell
- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [self.delegate addressWasChanged];
    [textField resignFirstResponder];
    
    return YES;
}

@end


@interface AddressZipTableViewCell() <UITextFieldDelegate>
@end

@implementation AddressZipTableViewCell
- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [self.delegate addressWasChanged];
    [textField resignFirstResponder];
    
    return YES;
}

@end

@interface AddressAddressHeaderView() <UITextFieldDelegate>

@end

@implementation AddressAddressHeaderView

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
    [self.delegate addressHeaderViewPressed];
}

@end

#pragma mark Category

@interface AddressCategoryTableViewCell()  <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;

@end

@implementation AddressCategoryTableViewCell


#pragma mark UITableViewDelegate

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressCategoryItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"CategoryItem"];
    
    return cell;
}

@end

@interface AddressCategoryItemTableViewCell()

@end

@implementation AddressCategoryItemTableViewCell

@end


@interface AddressCategoryHeaderView()

@end


@implementation AddressCategoryHeaderView

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
    [self.delegate categoryHeaderViewPressed];
}

- (void) shake
{
    [UIView shakeView: self];
}

@end

#pragma mark Location

@interface AddressLocationTableViewCell()

@end

@implementation AddressLocationTableViewCell

@end
